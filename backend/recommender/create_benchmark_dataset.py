import json
from pathlib import Path


CATEGORIES = [
    "Music",
    "Sports",
    "Art",
    "Technology",
    "Food",
    "Travel",
    "Fashion",
    "Gaming",
]

CITIES = [
    "Riyadh",
    "Jeddah",
    "Mecca",
    "Medina",
    "Dammam",
    "Khobar",
    "Dhahran",
    "Taif",
    "Tabuk",
    "Abha",
    "Khamis Mushait",
    "Buraidah",
    "Hail",
    "Najran",
    "Jubail",
    "Yanbu",
    "Al Ahsa",
    "Arar",
    "Sakaka",
    "Jazan",
]


def build_events():
    events = []
    event_index = 1
    for category_index, category in enumerate(CATEGORIES):
        for offset in range(5):
            city = CITIES[(category_index * 3 + offset) % len(CITIES)]
            price = [0, 45, 90, 150, 250][offset]
            events.append(
                {
                    "event_id": f"bench_event_{event_index:03d}",
                    "event_name": f"{category} Benchmark Event {offset + 1}",
                    "category": category,
                    "city": city,
                    "event_status": "approved",
                    "ticket_type1_price": price,
                    "ticket_sold": 5 + ((event_index * 7) % 80),
                    "sales": price * (5 + ((event_index * 7) % 80)),
                    "organizer_id": f"bench_org_{(category_index % 6) + 1}",
                }
            )
            event_index += 1
    return events


def relevance_score(attendee, interests, event):
    score = 0
    reasons = []

    if event["category"] == interests[0]:
        score += 100
        reasons.append("primary_category")
    elif event["category"] == interests[1]:
        score += 70
        reasons.append("secondary_category")

    if event["city"] == attendee["city"]:
        score += 30
        reasons.append("same_city")

    if event["ticket_type1_price"] <= attendee["max_price"]:
        score += 15
        reasons.append("within_budget")

    score += min(event["ticket_sold"], 60) / 10
    return score, reasons


def build_benchmark_dataset():
    events = build_events()
    attendees = []
    interests_by_user = {}
    interactions = []
    ground_truth = {}

    for index in range(100):
        attendee_id = f"bench_attendee_{index + 1:03d}"
        primary = CATEGORIES[index % len(CATEGORIES)]
        secondary = CATEGORIES[(index + 3) % len(CATEGORIES)]
        city = CITIES[(index * 2) % len(CITIES)]
        max_price = [50, 100, 180, 300][index % 4]

        attendee = {
            "attendee_id": attendee_id,
            "city": city,
            "gender": "male" if index % 2 == 0 else "female",
            "max_price": max_price,
        }
        attendees.append(attendee)
        interests_by_user[attendee_id] = [primary, secondary]

        scored_events = []
        for event in events:
            score, reasons = relevance_score(attendee, [primary, secondary], event)
            if score >= 70:
                scored_events.append(
                    {
                        "event_id": event["event_id"],
                        "score": round(score, 2),
                        "reasons": reasons,
                    }
                )

        scored_events.sort(key=lambda row: (-row["score"], row["event_id"]))
        relevant_event_ids = [row["event_id"] for row in scored_events]
        ground_truth[attendee_id] = {
            "primary_category": primary,
            "secondary_category": secondary,
            "city": city,
            "max_price": max_price,
            "relevant_events": scored_events,
            "top_5_relevant_event_ids": relevant_event_ids[:5],
        }

        for rank, event_id in enumerate(relevant_event_ids[:8]):
            interaction_type = "purchase" if rank < 2 else "like" if rank < 5 else "view"
            interaction_value = 5 if interaction_type == "purchase" else 3 if interaction_type == "like" else 1
            interactions.append(
                {
                    "attendee_id": attendee_id,
                    "event_id": event_id,
                    "interaction_type": interaction_type,
                    "interaction_value": interaction_value,
                    "ground_truth_positive": True,
                }
            )

        negative_pool = [
            event
            for event in events
            if event["event_id"] not in relevant_event_ids
            and event["category"] not in {primary, secondary}
            and event["city"] != city
        ]
        for offset in range(2):
            event = negative_pool[(index + offset) % len(negative_pool)]
            interactions.append(
                {
                    "attendee_id": attendee_id,
                    "event_id": event["event_id"],
                    "interaction_type": "view",
                    "interaction_value": 1,
                    "ground_truth_positive": False,
                }
            )

    return {
        "metadata": {
            "name": "Jadwal synthetic recommendation benchmark",
            "version": 1,
            "attendee_count": len(attendees),
            "event_count": len(events),
            "interaction_count": len(interactions),
            "categories": CATEGORIES,
            "cities": CITIES,
            "signal_weights": {
                "purchase": 5,
                "like": 3,
                "view": 1,
            },
            "ground_truth_rule": (
                "An event is relevant when it matches the attendee primary category, "
                "secondary category, city, and/or budget. Primary category is strongest, "
                "secondary category is medium, same city and budget are supporting signals."
            ),
        },
        "attendees": attendees,
        "events": events,
        "interests_by_user": interests_by_user,
        "interactions": interactions,
        "ground_truth": ground_truth,
    }


def main():
    output_path = Path(__file__).with_name("benchmark_dataset.json")
    dataset = build_benchmark_dataset()
    output_path.write_text(json.dumps(dataset, indent=2), encoding="utf-8")
    print(f"Saved {output_path}")
    print(f"Attendees: {dataset['metadata']['attendee_count']}")
    print(f"Events: {dataset['metadata']['event_count']}")
    print(f"Interactions: {dataset['metadata']['interaction_count']}")


if __name__ == "__main__":
    main()
