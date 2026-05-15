from collections import Counter

try:
    import joblib
    from lightfm import LightFM
    from lightfm.data import Dataset
    from scipy import sparse
except ImportError:
    from common import fail

    fail(
        "LightFM is not installed. Run: python -m pip install -r recommender/requirements.txt"
    )

from common import (
    MODEL_DIR,
    MODEL_PATH,
    event_features,
    fail,
    load_recommender_data,
    popularity_score,
    user_features,
)

INTERACTION_WEIGHTS = {
    "view": 1.0,
    "like": 3.0,
}
PURCHASE_WEIGHT = 5.0


def save_artifact(data, attendees, events, dataset, interaction_weights, model=None, interactions=None, sample_weights=None, user_feature_matrix=None, item_feature_matrix=None):
    attendee_ids = [row["attendee_id"] for row in attendees if row.get("attendee_id")]
    event_ids = [row["event_id"] for row in events if row.get("event_id")]
    event_by_id = {event["event_id"]: event for event in events if event.get("event_id")}
    attendee_by_id = {
        attendee["attendee_id"]: attendee
        for attendee in attendees
        if attendee.get("attendee_id")
    }
    popularity_by_event = {
        event_id: popularity_score(
            event, data["like_counts"], data["purchase_counts"]
        )
        for event_id, event in event_by_id.items()
    }

    MODEL_DIR.mkdir(parents=True, exist_ok=True)
    joblib.dump(
        {
            "model": model,
            "dataset": dataset,
            "interactions": interactions,
            "sample_weights": sample_weights,
            "user_features": user_feature_matrix,
            "item_features": item_feature_matrix,
            "attendee_ids": attendee_ids,
            "event_ids": event_ids,
            "event_by_id": event_by_id,
            "attendee_by_id": attendee_by_id,
            "interacted_by_user": {
                user_id: [
                    event_id
                    for (candidate_user, event_id), _ in interaction_weights.items()
                    if candidate_user == user_id
                ]
                for user_id in attendee_ids
            },
            "purchased_by_user": data["purchased_by_user"],
            "interests_by_user": data["interests_by_user"],
            "popularity_by_event": popularity_by_event,
            "signal_weights": {
                **INTERACTION_WEIGHTS,
                "purchase": PURCHASE_WEIGHT,
            },
        },
        MODEL_PATH,
    )


def main():
    print("Loading Supabase data...", flush=True)
    data = load_recommender_data()
    attendees = data["attendees"]
    events = data["events"]

    if not attendees:
        fail("No attendees found in Supabase.")
    if not events:
        fail("No approved events found in Supabase.")

    attendee_ids = [row["attendee_id"] for row in attendees if row.get("attendee_id")]
    event_ids = [row["event_id"] for row in events if row.get("event_id")]

    valid_users = set(attendee_ids)
    valid_events = set(event_ids)
    interaction_weights = Counter()

    for row in data["interactions"]:
        attendee_id = row.get("attendee_id")
        event_id = row.get("event_id")
        if attendee_id not in valid_users or event_id not in valid_events:
            continue
        interaction_type = str(row.get("interaction_type", "")).lower()
        weight = INTERACTION_WEIGHTS.get(interaction_type)
        if weight:
            interaction_weights[(attendee_id, event_id)] += weight

    for row in data["tickets"]:
        attendee_id = row.get("attendee_id")
        event_id = row.get("event_id")
        if attendee_id in valid_users and event_id in valid_events:
            interaction_weights[(attendee_id, event_id)] += PURCHASE_WEIGHT

    training_attendee_ids = sorted(
        {attendee_id for attendee_id, _ in interaction_weights.keys()}
    )
    dataset = Dataset(user_identity_features=True, item_identity_features=True)
    print("Building LightFM dataset...", flush=True)
    dataset.fit(users=training_attendee_ids or attendee_ids, items=event_ids)

    if not interaction_weights:
        save_artifact(data, attendees, events, dataset, interaction_weights)
        print("No likes or purchases found, so saved a fallback-only recommendation artifact.")
        print(f"Saved model data to {MODEL_PATH}")
        return

    print("Building interaction and feature matrices...", flush=True)
    user_id_map, _, item_id_map, _ = dataset.mapping()
    interaction_pairs = list(interaction_weights.items())
    rows = [user_id_map[user_id] for (user_id, _), _ in interaction_pairs]
    cols = [item_id_map[event_id] for (_, event_id), _ in interaction_pairs]
    interactions = sparse.coo_matrix(
        ([1] * len(interaction_pairs), (rows, cols)),
        shape=(len(user_id_map), len(item_id_map)),
        dtype="int32",
    )
    sample_weights = sparse.coo_matrix(
        ([float(weight) for _, weight in interaction_pairs], (rows, cols)),
        shape=(len(user_id_map), len(item_id_map)),
        dtype="float32",
    )

    model = LightFM(loss="logistic", no_components=32, random_state=42)
    print("Training LightFM model...", flush=True)
    model.fit(
        interactions,
        sample_weight=sample_weights,
        epochs=30,
        num_threads=1,
    )

    print("Saving model artifact...", flush=True)
    save_artifact(
        data,
        attendees,
        events,
        dataset,
        interaction_weights,
        model=model,
        interactions=interactions,
        sample_weights=sample_weights,
        user_feature_matrix=None,
        item_feature_matrix=None,
    )

    print(f"Trained LightFM model with {len(training_attendee_ids)} active users, {len(event_ids)} approved events, and {len(interaction_weights)} weighted interactions.")
    print("Loss: logistic")
    print("Epochs: 30")
    print(f"Saved model to {MODEL_PATH}")


if __name__ == "__main__":
    main()
