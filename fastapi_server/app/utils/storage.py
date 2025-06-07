from google.cloud import storage
from app.core.config import settings


def get_storage_client():
    """Get Google Cloud Storage client."""
    if not settings.GOOGLE_STORAGE_CREDENTIALS:
        raise ValueError("GOOGLE_FIREBASE_CREDENTIALS is not set in settings.")

    return storage.Client.from_service_account_json(settings.GOOGLE_STORAGE_CREDENTIALS)


storage_client = get_storage_client()
