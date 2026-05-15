import json
import os
from collections import Counter, defaultdict
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[1]
MODEL_DIR = Path(__file__).resolve().parent / "models"
MODEL_PATH = MODEL_DIR / "jadwal_lightfm.joblib"


def fail(message, code=1):
    print(json.dumps({"ok": False, "error": message}), flush=True)
    raise SystemExit(code)


def get_supabase():
    try:
        from dotenv import load_dotenv
        from supabase import create_client
    except ImportError:
        fail(
            "Python dependencies are missing. Run: python -m pip install -r recommender/requirements.txt"
        )

    load_dotenv(ROOT_DIR / ".env")
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_KEY")

    if not url or not key:
        fail("Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in backend/.env")

    return create_client(url, key)


def fetch_all(client, table, columns="*"):
    rows = []
    start = 0
    page_size = 1000

    while True:
        result = (
            client.table(table)
            .select(columns)
            .range(start, start + page_size - 1)
            .execute()
        )
        data = result.data or []
        rows.extend(data)

        if len(data) < page_size:
            return rows

        start += page_size


def normalize_text(value):
    if value is None:
        return ""
    return str(value).strip().lower()


def event_price(event):
    prices = []
    for key in ("ticket_type1_price", "ticket_type2_price"):
        value = event.get(key)
        if isinstance(value, (int, float)):
            prices.append(float(value))
    return min(prices) if prices else 0.0


def price_bucket(price):
    if price <= 0:
        return "price:free_or_unknown"
    if price <= 50:
        return "price:low"
    if price <= 150:
        return "price:mid"
    return "price:high"


def event_features(event):
    features = []
    category = normalize_text(event.get("category"))
    city = normalize_text(event.get("city"))
    organizer = normalize_text(event.get("organizer_id"))

    if category:
        features.append(f"category:{category}")
    if city:
        features.append(f"city:{city}")
    if organizer:
        features.append(f"organizer:{organizer}")
    features.append(price_bucket(event_price(event)))

    return features


def user_features(attendee, interests_by_user):
    user_id = attendee.get("attendee_id")
    features = []

    for interest in interests_by_user.get(user_id, []):
        normalized = normalize_text(interest)
        if normalized:
            features.append(f"interest:{normalized}")
            features.append(f"category:{normalized}")

    city = normalize_text(attendee.get("city"))
    gender = normalize_text(attendee.get("gender"))
    if city:
        features.append(f"city:{city}")
    if gender:
        features.append(f"gender:{gender}")

    return features


def load_recommender_data():
    client = get_supabase()

    attendees = fetch_all(client, "Attendee")
    events = fetch_all(client, "Event")
    interactions = fetch_all(client, "Interaction")
    tickets = fetch_all(client, "Ticket")
    interests = fetch_all(client, "Attendee_Interests")

    interests_by_user = defaultdict(list)
    for row in interests:
        attendee_id = row.get("attendee_id")
        if attendee_id:
            interests_by_user[attendee_id].append(row.get("interests"))

    approved_events = [
        event for event in events if normalize_text(event.get("event_status")) == "approved"
    ]

    like_counts = Counter()
    interaction_counts = Counter()
    for row in interactions:
        event_id = row.get("event_id")
        interaction_type = normalize_text(row.get("interaction_type"))
        if event_id and interaction_type:
            interaction_counts[(event_id, interaction_type)] += 1
        if interaction_type == "like" and event_id:
            like_counts[event_id] += 1

    purchased_by_user = defaultdict(set)
    purchase_counts = Counter()
    for row in tickets:
        attendee_id = row.get("attendee_id")
        event_id = row.get("event_id")
        if attendee_id and event_id:
            purchased_by_user[attendee_id].add(event_id)
            purchase_counts[event_id] += 1

    return {
        "attendees": attendees,
        "events": approved_events,
        "interactions": interactions,
        "tickets": tickets,
        "interests_by_user": dict(interests_by_user),
        "like_counts": dict(like_counts),
        "interaction_counts": {
            f"{event_id}:{interaction_type}": count
            for (event_id, interaction_type), count in interaction_counts.items()
        },
        "purchase_counts": dict(purchase_counts),
        "purchased_by_user": {key: list(value) for key, value in purchased_by_user.items()},
    }


def popularity_score(event, like_counts, purchase_counts):
    event_id = event.get("event_id")
    tickets_sold = event.get("ticket_sold") or 0
    sales = event.get("sales") or 0

    return (
        float(purchase_counts.get(event_id, 0)) * 5.0
        + float(like_counts.get(event_id, 0)) * 3.0
        + float(tickets_sold) * 2.0
        + float(sales) / 1000.0
    )
