from fastapi import APIRouter
from app.core.errors import APIError
from app.models.auth_models import AuthRequest, AuthResponse
from app.utils.firestore import firestore_client
from app.core.logging import logger
from datetime import timezone, datetime

auth_router = APIRouter()


@auth_router.post("/signin", response_model=AuthResponse)
async def create_or_get_account(account_data: AuthRequest):
    try:

        profiles_ref = firestore_client.collection("profiles")
        query = profiles_ref.where("user_id", "==", account_data.google_id).limit(1)
        existing_profiles = list(query.stream())
        current_time = datetime.now(timezone.utc)

        logger.info(existing_profiles)

        if existing_profiles:
            profile_doc = existing_profiles[0]
            profile_data = profile_doc.to_dict()
            if profile_data is None:
                raise APIError(
                    status_code=500,
                    detail="Error retrieving profile data from Firestore.",
                )
        else:
            logger.info(True)
            new_profile_data = {
                "user_id": account_data.google_id,
                "email": account_data.email,
                "display_name": account_data.display_name,
                "photo_url": account_data.photo_url,
                "eco_points": 0,
                "total_scans": 0,
                "created_at": current_time,
                "updated_at": current_time,
            }

            try:
                profiles_ref.add(new_profile_data)
            except Exception as e:
                raise APIError(
                    status_code=500,
                    detail=f"Error creating new profile in Firestore: {str(e)}",
                )
            profile_data = new_profile_data.copy()
            logger.info(f"Created new user: {account_data.google_id}")

        return AuthResponse(**profile_data)

    except Exception as e:
        raise APIError(status_code=500, detail=f"Error accessing Firestore: {str(e)}")
