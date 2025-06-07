from google.cloud import firestore
from app.core.config import settings


def get_firestore_client() -> firestore.Client:
    """Get Firestore client."""
    if not settings.GOOGLE_FIREBASE_CREDENTIALS:
        raise ValueError("GOOGLE_FIREBASE_CREDENTIALS is not set in settings.")

    return firestore.Client.from_service_account_json(
        settings.GOOGLE_FIREBASE_CREDENTIALS
    )


firestore_client = get_firestore_client()
