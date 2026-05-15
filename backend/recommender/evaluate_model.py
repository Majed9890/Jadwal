from collections import defaultdict
from random import Random

import numpy as np
from lightfm import LightFM
from lightfm.data import Dataset
from lightfm.evaluation import auc_score, precision_at_k
from scipy import sparse

from common import event_features, user_features
from demo_dataset import build_demo_dataset


def split_interactions(interactions):
    by_user = defaultdict(list)
    for row in interactions:
        by_user[row["attendee_id"]].append(row)

    train_rows = []
    test_rows = []
    for attendee_id, rows in by_user.items():
        rows = list(rows)
        Random(attendee_id).shuffle(rows)
        split_at = max(1, int(len(rows) * 0.8))
        train_rows.extend(rows[:split_at])
        test_rows.extend(rows[split_at:])

    return train_rows, test_rows


def build_interaction_matrix(dataset, rows):
    weights = defaultdict(float)
    for row in rows:
        weights[(row["attendee_id"], row["event_id"])] += float(row["interaction_value"])

    user_id_map, _, item_id_map, _ = dataset.mapping()
    interaction_pairs = list(weights.items())
    matrix_rows = [user_id_map[attendee_id] for (attendee_id, _), _ in interaction_pairs]
    matrix_cols = [item_id_map[event_id] for (_, event_id), _ in interaction_pairs]
    return sparse.coo_matrix(
        ([1] * len(interaction_pairs), (matrix_rows, matrix_cols)),
        shape=(len(user_id_map), len(item_id_map)),
        dtype="int32",
    )


def manual_recall_at_k(model, dataset, train_interactions, test_interactions, user_features_matrix, item_features_matrix, k=5):
    user_id_map, _, item_id_map, _ = dataset.mapping()
    item_ids_by_internal = {internal: external for external, internal in item_id_map.items()}
    recalls = []

    train_csr = train_interactions.tocsr()
    test_csr = test_interactions.tocsr()

    for attendee_id, user_internal_id in user_id_map.items():
        test_items = set(test_csr[user_internal_id].indices.tolist())
        if not test_items:
            continue

        item_internal_ids = np.arange(len(item_id_map), dtype=np.int32)
        user_internal_ids = np.full(len(item_internal_ids), user_internal_id, dtype=np.int32)
        predict_kwargs = {"num_threads": 1}
        if user_features_matrix is not None:
            predict_kwargs["user_features"] = user_features_matrix
        if item_features_matrix is not None:
            predict_kwargs["item_features"] = item_features_matrix
        scores = model.predict(
            user_internal_ids,
            item_internal_ids,
            **predict_kwargs,
        )

        train_items = set(train_csr[user_internal_id].indices.tolist())
        ranked_items = [
            item_internal
            for item_internal in np.argsort(-scores)
            if item_internal not in train_items and item_ids_by_internal.get(item_internal)
        ][:k]

        hits = len(set(ranked_items) & test_items)
        recalls.append(hits / len(test_items))

    return float(np.mean(recalls)) if recalls else 0.0


def category_match_at_k(model, dataset, attendees, events, interests_by_user, train_interactions, user_features_matrix, item_features_matrix, k=5):
    user_id_map, _, item_id_map, _ = dataset.mapping()
    event_by_internal = {
        internal: next(event for event in events if event["event_id"] == event_id)
        for event_id, internal in item_id_map.items()
    }
    train_csr = train_interactions.tocsr()
    matches = []

    for attendee in attendees:
        attendee_id = attendee["attendee_id"]
        user_internal_id = user_id_map[attendee_id]
        desired_categories = {
            interest.lower()
            for interest in interests_by_user.get(attendee_id, [])
        }

        item_internal_ids = np.arange(len(item_id_map), dtype=np.int32)
        user_internal_ids = np.full(len(item_internal_ids), user_internal_id, dtype=np.int32)
        predict_kwargs = {"num_threads": 1}
        if user_features_matrix is not None:
            predict_kwargs["user_features"] = user_features_matrix
        if item_features_matrix is not None:
            predict_kwargs["item_features"] = item_features_matrix
        scores = model.predict(
            user_internal_ids,
            item_internal_ids,
            **predict_kwargs,
        )

        train_items = set(train_csr[user_internal_id].indices.tolist())
        ranked_items = [
            item_internal
            for item_internal in np.argsort(-scores)
            if item_internal not in train_items
        ][:k]

        if not ranked_items:
            continue

        hits = 0
        for item_internal in ranked_items:
            category = event_by_internal[item_internal]["category"].lower()
            if category in desired_categories:
                hits += 1
        matches.append(hits / len(ranked_items))

    return float(np.mean(matches)) if matches else 0.0


def main():
    data = build_demo_dataset()
    attendees = data["attendees"]
    events = data["events"]
    attendee_ids = [attendee["attendee_id"] for attendee in attendees]
    event_ids = [event["event_id"] for event in events]

    train_rows, test_rows = split_interactions(data["interactions"])

    all_user_features = sorted({
        feature
        for attendee in attendees
        for feature in user_features(attendee, data["interests_by_user"])
    })
    all_item_features = sorted({
        feature
        for event in events
        for feature in event_features(event)
    })

    dataset = Dataset(user_identity_features=True, item_identity_features=True)
    dataset.fit(
        users=attendee_ids,
        items=event_ids,
        user_features=all_user_features,
        item_features=all_item_features,
    )

    train_interactions = build_interaction_matrix(dataset, train_rows)
    test_interactions = build_interaction_matrix(dataset, test_rows)
    user_features_matrix = dataset.build_user_features(
        (attendee["attendee_id"], user_features(attendee, data["interests_by_user"]))
        for attendee in attendees
    )
    item_features_matrix = dataset.build_item_features(
        (event["event_id"], event_features(event))
        for event in events
    )

    model = LightFM(loss="logistic", no_components=32, random_state=42)
    model.fit(
        train_interactions,
        epochs=30,
        num_threads=1,
    )

    precision = precision_at_k(
        model,
        test_interactions,
        train_interactions=train_interactions,
        k=5,
        num_threads=1,
    ).mean()
    recall = manual_recall_at_k(
        model,
        dataset,
        train_interactions,
        test_interactions,
        None,
        None,
        k=5,
    )
    category_match = category_match_at_k(
        model,
        dataset,
        attendees,
        events,
        data["interests_by_user"],
        train_interactions,
        None,
        None,
        k=5,
    )
    auc = auc_score(
        model,
        test_interactions,
        train_interactions=train_interactions,
        num_threads=1,
    ).mean()

    print("Synthetic recommendation evaluation")
    print(f"Attendees: {len(attendees)}")
    print(f"Events: {len(events)}")
    print(f"Interactions: {len(data['interactions'])}")
    print(f"Train interactions: {len(train_rows)}")
    print(f"Test interactions: {len(test_rows)}")
    print("Model: LightFM(loss=logistic, no_components=32, epochs=30)")
    print(f"precision@5: {precision:.3f}")
    print(f"recall@5: {recall:.3f}")
    print(f"AUC: {auc:.3f}")
    print(f"category_match@5: {category_match:.3f}")


if __name__ == "__main__":
    main()
