CATEGORIES = ["Music", "Art", "Sports", "Nature", "Food", "Tech"]
CITIES = ["Riyadh", "Jeddah", "Dammam", "Abha", "Madinah"]


def build_demo_dataset():
    attendees = []
    interests_by_user = {}
    events = []
    interactions = []

    for index in range(50):
        attendee_id = f"demo_attendee_{index + 1:02d}"
        favorite_category = CATEGORIES[index % len(CATEGORIES)]
        secondary_category = CATEGORIES[(index + 2) % len(CATEGORIES)]
        city = CITIES[index % len(CITIES)]

        attendees.append({
            "attendee_id": attendee_id,
            "city": city,
            "gender": "male" if index % 2 == 0 else "female",
        })
        interests_by_user[attendee_id] = [favorite_category, secondary_category]

    for index in range(30):
        category = CATEGORIES[index % len(CATEGORIES)]
        city = CITIES[(index * 2) % len(CITIES)]
        events.append({
            "event_id": f"demo_event_{index + 1:02d}",
            "event_name": f"{category} Event {index + 1}",
            "category": category,
            "city": city,
            "organizer_id": f"demo_org_{(index % 5) + 1}",
            "ticket_type1_price": [0, 35, 90, 180, 250][index % 5],
            "event_status": "approved",
        })

    action_weights = [
        ("view", 1.0),
        ("like", 3.0),
        ("purchase", 5.0),
    ]

    for attendee_index, attendee in enumerate(attendees):
        attendee_id = attendee["attendee_id"]
        interests = set(interests_by_user[attendee_id])
        preferred = [
            event for event in events
            if event["category"] in interests or event["city"] == attendee["city"]
        ]
        exploration = [
            event for event in events
            if event["category"] not in interests and event["city"] != attendee["city"]
        ]

        for offset in range(12):
            event = preferred[(attendee_index + offset) % len(preferred)]
            action, weight = action_weights[(attendee_index + offset) % len(action_weights)]
            interactions.append({
                "attendee_id": attendee_id,
                "event_id": event["event_id"],
                "interaction_type": action,
                "interaction_value": weight,
            })

        for offset in range(1):
            event = exploration[(attendee_index + offset) % len(exploration)]
            interactions.append({
                "attendee_id": attendee_id,
                "event_id": event["event_id"],
                "interaction_type": "view",
                "interaction_value": 1.0,
            })

    return {
        "attendees": attendees,
        "events": events,
        "interactions": interactions,
        "interests_by_user": interests_by_user,
    }
