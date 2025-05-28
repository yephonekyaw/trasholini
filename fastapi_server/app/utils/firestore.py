from google.cloud import firestore  # type: ignore
from app.core.config import settings


def get_firestore_client() -> firestore.Client:
    """Get Firestore client."""
    if not settings.GOOGLE_APPLICATION_CREDENTIALS:
        raise ValueError("GOOGLE_APPLICATION_CREDENTIALS is not set in settings.")

    return firestore.Client.from_service_account_json(  # type: ignore
        settings.GOOGLE_APPLICATION_CREDENTIALS
    )


firestore_client = get_firestore_client()
