import json
import sys

try:
    import joblib
    import lightfm  # noqa: F401
    import numpy as np
except ImportError:
    from common import fail

    fail(
        "LightFM is not installed. Run: python -m pip install -r recommender/requirements.txt"
    )

from common import (
    MODEL_PATH,
    event_price,
    fail,
    load_recommender_data,
    normalize_text,
    popularity_score,
)


def refresh_artifact_with_current_data(artifact):
    try:
        data = load_recommender_data()
    except Exception:
        return artifact

    current_events = {
        event["event_id"]: event
        for event in data["events"]
        if event.get("event_id")
    }
    existing_order = [
        event_id for event_id in artifact["event_ids"] if event_id in current_events
    ]
    new_event_ids = sorted(
        [event_id for event_id in current_events if event_id not in existing_order],
        key=lambda event_id: (
            normalize_text(current_events[event_id].get("event_name")),
            event_id,
        ),
    )

    artifact["event_ids"] = existing_order + new_event_ids
    artifact["event_by_id"] = current_events
    artifact["attendee_by_id"] = {
        attendee["attendee_id"]: attendee
        for attendee in data["attendees"]
        if attendee.get("attendee_id")
    }
    artifact["purchased_by_user"] = data["purchased_by_user"]
    artifact["interests_by_user"] = data["interests_by_user"]
    artifact["popularity_by_event"] = {
        event_id: popularity_score(
            event,
            data["like_counts"],
            data["purchase_counts"],
        )
        for event_id, event in current_events.items()
    }

    interacted_by_user = {}
    for row in data["interactions"]:
        attendee_id = row.get("attendee_id")
        event_id = row.get("event_id")
        if attendee_id and event_id:
            interacted_by_user.setdefault(attendee_id, set()).add(event_id)
    for row in data["tickets"]:
        attendee_id = row.get("attendee_id")
        event_id = row.get("event_id")
        if attendee_id and event_id:
            interacted_by_user.setdefault(attendee_id, set()).add(event_id)
    artifact["interacted_by_user"] = {
        attendee_id: sorted(event_ids)
        for attendee_id, event_ids in interacted_by_user.items()
    }
    return artifact


def attendee_context(artifact, attendee_id):
    attendee = artifact["attendee_by_id"].get(attendee_id, {})
    interests = {
        normalize_text(value)
        for value in artifact["interests_by_user"].get(attendee_id, [])
        if normalize_text(value)
    }
    return attendee, normalize_text(attendee.get("city")), interests


def supplemental_score(artifact, attendee_city, interests, purchased, event_id):
    event = artifact["event_by_id"][event_id]
    score = artifact["popularity_by_event"].get(event_id, 0.0) * 0.001
    if normalize_text(event.get("category")) in interests:
        score += 0.25
    if attendee_city and attendee_city == normalize_text(event.get("city")):
        score += 0.10
    if event_id in purchased:
        score -= 0.05
    return score


def fallback_recommendations(artifact, attendee_id, limit):
    _, attendee_city, interests = attendee_context(artifact, attendee_id)
    purchased = set(artifact["purchased_by_user"].get(attendee_id, []))

    ranked = []
    for event_id in artifact["event_ids"]:
        event = artifact["event_by_id"][event_id]
        category = normalize_text(event.get("category"))
        city = normalize_text(event.get("city"))

        score = artifact["popularity_by_event"].get(event_id, 0.0)
        if category in interests:
            score += 50.0
        if attendee_city and attendee_city == city:
            score += 10.0
        if event_id in purchased:
            score -= 5.0

        ranked.append((score, event_id))

    ranked.sort(
        key=lambda pair: (
            -pair[0],
            normalize_text(artifact["event_by_id"][pair[1]].get("event_name")),
            pair[1],
        )
    )
    return ranked[:limit] if limit else ranked


def lightfm_recommendations(artifact, attendee_id, limit):
    user_id_map, _, item_id_map, _ = artifact["dataset"].mapping()
    if attendee_id not in user_id_map:
        return fallback_recommendations(artifact, attendee_id, limit), "fallback"

    user_internal_id = user_id_map[attendee_id]
    purchased = set(artifact["purchased_by_user"].get(attendee_id, []))
    candidate_event_ids = list(artifact["event_ids"])

    if not candidate_event_ids:
        return [], "lightfm"

    known_event_ids = [
        event_id for event_id in candidate_event_ids if event_id in item_id_map
    ]
    new_event_ids = [
        event_id for event_id in candidate_event_ids if event_id not in item_id_map
    ]

    predict_kwargs = {"num_threads": 1}
    if artifact.get("user_features") is not None:
        predict_kwargs["user_features"] = artifact["user_features"]
    if artifact.get("item_features") is not None:
        predict_kwargs["item_features"] = artifact["item_features"]

    _, attendee_city, interests = attendee_context(artifact, attendee_id)

    adjusted_scores = []
    if known_event_ids:
        item_internal_ids = np.array(
            [item_id_map[event_id] for event_id in known_event_ids], dtype=np.int32
        )
        user_internal_ids = np.full(
            len(item_internal_ids), user_internal_id, dtype=np.int32
        )
        scores = artifact["model"].predict(
            user_internal_ids,
            item_internal_ids,
            **predict_kwargs,
        )
        for score, event_id in zip(scores.tolist(), known_event_ids):
            adjusted_score = float(score)
            adjusted_score += supplemental_score(
                artifact, attendee_city, interests, purchased, event_id
            )
            adjusted_scores.append((adjusted_score, event_id))

    for event_id in new_event_ids:
        adjusted_score = supplemental_score(
            artifact, attendee_city, interests, purchased, event_id
        )
        adjusted_scores.append((adjusted_score, event_id))

    ranked = sorted(
        adjusted_scores,
        key=lambda pair: (
            -pair[0],
            normalize_text(artifact["event_by_id"][pair[1]].get("event_name")),
            pair[1],
        ),
    )
    return (ranked[:limit] if limit else ranked), "lightfm"


def format_results(artifact, ranked, source, attendee_id):
    purchased = set(artifact["purchased_by_user"].get(attendee_id, []))
    results = []
    for rank, (score, event_id) in enumerate(ranked, start=1):
        event = artifact["event_by_id"][event_id]
        result = dict(event)
        result.update({
            "rank": rank,
            "price": event_price(event),
            "score": round(float(score), 4),
            "source": source,
            "already_purchased": event_id in purchased,
        })
        results.append(result)
    return results


def main():
    attendee_id = sys.argv[1] if len(sys.argv) >= 2 else ""
    limit = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] else None

    if not MODEL_PATH.exists():
        fail("Model is missing. Run: npm run reco:train")

    artifact = joblib.load(MODEL_PATH)
    artifact = refresh_artifact_with_current_data(artifact)
    if not attendee_id or attendee_id == "undefined":
        attendee_id = artifact["attendee_ids"][0] if artifact["attendee_ids"] else ""
    if not attendee_id:
        fail("No attendee id available in the trained model.")

    has_interactions = bool(artifact["interacted_by_user"].get(attendee_id))
    if has_interactions:
        ranked, source = lightfm_recommendations(artifact, attendee_id, limit)
    else:
        ranked = fallback_recommendations(artifact, attendee_id, limit)
        source = "fallback"

    print(
        json.dumps(
            {
                "ok": True,
                "attendee_id": attendee_id,
                "source": source,
                "recommendations": format_results(artifact, ranked, source, attendee_id),
            },
            ensure_ascii=True,
        )
    )


if __name__ == "__main__":
    main()
