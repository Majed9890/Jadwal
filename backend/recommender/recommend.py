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

from common import MODEL_PATH, event_price, fail, normalize_text


def fallback_recommendations(artifact, attendee_id, limit):
    attendee = artifact["attendee_by_id"].get(attendee_id, {})
    interests = {
        normalize_text(value)
        for value in artifact["interests_by_user"].get(attendee_id, [])
        if normalize_text(value)
    }
    attendee_city = normalize_text(attendee.get("city"))
    purchased = set(artifact["purchased_by_user"].get(attendee_id, []))

    ranked = []
    for event_id in artifact["event_ids"]:
        if event_id in purchased:
            continue

        event = artifact["event_by_id"][event_id]
        category = normalize_text(event.get("category"))
        city = normalize_text(event.get("city"))

        score = artifact["popularity_by_event"].get(event_id, 0.0)
        if category in interests:
            score += 50.0
        if attendee_city and attendee_city == city:
            score += 10.0

        ranked.append((score, event_id))

    ranked.sort(reverse=True)
    return ranked[:limit]


def lightfm_recommendations(artifact, attendee_id, limit):
    user_id_map, _, item_id_map, _ = artifact["dataset"].mapping()
    if attendee_id not in user_id_map:
        return fallback_recommendations(artifact, attendee_id, limit), "fallback"

    purchased = set(artifact["purchased_by_user"].get(attendee_id, []))
    user_internal_id = user_id_map[attendee_id]
    candidate_event_ids = [
        event_id for event_id in artifact["event_ids"] if event_id not in purchased
    ]

    if not candidate_event_ids:
        return [], "lightfm"

    item_internal_ids = np.array(
        [item_id_map[event_id] for event_id in candidate_event_ids], dtype=np.int32
    )
    user_internal_ids = np.full(
        len(item_internal_ids), user_internal_id, dtype=np.int32
    )

    predict_kwargs = {"num_threads": 1}
    if artifact.get("user_features") is not None:
        predict_kwargs["user_features"] = artifact["user_features"]
    if artifact.get("item_features") is not None:
        predict_kwargs["item_features"] = artifact["item_features"]

    scores = artifact["model"].predict(
        user_internal_ids,
        item_internal_ids,
        **predict_kwargs,
    )

    attendee = artifact["attendee_by_id"].get(attendee_id, {})
    attendee_city = normalize_text(attendee.get("city"))
    interests = {
        normalize_text(value)
        for value in artifact["interests_by_user"].get(attendee_id, [])
        if normalize_text(value)
    }

    adjusted_scores = []
    for score, event_id in zip(scores.tolist(), candidate_event_ids):
        event = artifact["event_by_id"][event_id]
        adjusted_score = float(score)
        if normalize_text(event.get("category")) in interests:
            adjusted_score += 0.25
        if attendee_city and attendee_city == normalize_text(event.get("city")):
            adjusted_score += 0.10
        adjusted_score += artifact["popularity_by_event"].get(event_id, 0.0) * 0.001
        adjusted_scores.append(adjusted_score)

    ranked = sorted(
        zip(adjusted_scores, candidate_event_ids),
        key=lambda pair: pair[0],
        reverse=True,
    )
    return ranked[:limit], "lightfm"


def format_results(artifact, ranked, source):
    results = []
    for rank, (score, event_id) in enumerate(ranked, start=1):
        event = artifact["event_by_id"][event_id]
        result = dict(event)
        result.update({
            "rank": rank,
            "price": event_price(event),
            "score": round(float(score), 4),
            "source": source,
        })
        results.append(result)
    return results


def main():
    attendee_id = sys.argv[1] if len(sys.argv) >= 2 else ""
    limit = int(sys.argv[2]) if len(sys.argv) > 2 else 10

    if not MODEL_PATH.exists():
        fail("Model is missing. Run: npm run reco:train")

    artifact = joblib.load(MODEL_PATH)
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
                "recommendations": format_results(artifact, ranked, source),
            },
            ensure_ascii=True,
        )
    )


if __name__ == "__main__":
    main()
