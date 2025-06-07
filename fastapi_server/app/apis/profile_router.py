import uuid
import mimetypes
from datetime import datetime
from typing import Dict, Any, Optional
from fastapi import APIRouter, HTTPException, Request, UploadFile, File, Form
from pydantic import BaseModel
from app.utils.storage import storage_client
from google.cloud.firestore import FieldFilter

from app.utils.extract_user_id import get_user_id
from app.utils.firestore import firestore_client
from app.core.config import settings
from app.core.logging import logger

profile_router = APIRouter()


class UpdateProfileRequest(BaseModel):
    display_name: Optional[str] = None


class ProfileUpdateResponse(BaseModel):
    success: bool
    message: str
    user_profile: Dict[str, Any]


def is_valid_image_file(file: UploadFile) -> bool:
    """
    Validate that the uploaded file is a valid image
    """
    try:
        # Check file extension
        if file.filename:
            filename_lower = file.filename.lower()
            valid_extensions = [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp"]
            has_valid_extension = any(
                filename_lower.endswith(ext) for ext in valid_extensions
            )
            if has_valid_extension:
                return True

        # Check MIME type
        if file.content_type and file.content_type.startswith("image/"):
            return True

        # Guess MIME type from filename
        if file.filename:
            guessed_type, _ = mimetypes.guess_type(file.filename)
            if guessed_type and guessed_type.startswith("image/"):
                return True

        return False

    except Exception as e:
        logger.error(f"Error validating image file: {e}")
        return False


async def upload_profile_image_to_gcs(
    file: UploadFile, user_id: str, bucket_name: str = ""
) -> str:
    """
    Upload profile image to Google Cloud Storage and return public URL
    """
    try:
        # Use default bucket name if not provided
        if not bucket_name:
            bucket_name = settings.GCS_BUCKET_NAME

        logger.info(f"Uploading profile image to GCS bucket: {bucket_name}")

        # Read file content
        file_content = await file.read()
        await file.seek(0)

        # Generate unique filename
        file_extension = ""
        if file.filename:
            file_extension = (
                file.filename.split(".")[-1] if "." in file.filename else "jpg"
            )
        else:
            file_extension = "jpg"

        # Create unique filename: profile-images/{user_id}/{timestamp}_{uuid}.{extension}
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        unique_id = str(uuid.uuid4())[:8]
        blob_name = f"profile-images/{user_id}/{timestamp}_{unique_id}.{file_extension}"

        logger.info(f"Generated blob name: {blob_name}")

        # Get bucket and create blob
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_name)

        # Set content type
        content_type = file.content_type or f"image/{file_extension}"
        blob.content_type = content_type

        # Upload file
        blob.upload_from_string(file_content, content_type=content_type)

        # Make the blob publicly accessible
        blob.make_public()

        # Get public URL
        public_url = blob.public_url

        logger.info(f"Profile image uploaded successfully. Public URL: {public_url}")
        return public_url

    except Exception as e:
        logger.error(f"Error uploading profile image to GCS: {str(e)}")
        raise HTTPException(
            status_code=500, detail=f"Failed to upload profile image: {str(e)}"
        )


@profile_router.put("/update", response_model=ProfileUpdateResponse)
async def update_user_profile(
    request: Request,
    display_name: Optional[str] = Form(None),
    profile_image: Optional[UploadFile] = File(None),
):
    """
    Update user profile with new display name and/or profile image
    """
    try:
        user_id = get_user_id(request)
        logger.info(f"Updating profile for user: {user_id}")

        update_data = {}
        new_photo_url = None

        # Handle profile image upload
        if profile_image and profile_image.filename:
            logger.info(f"Processing profile image upload: {profile_image.filename}")

            # Validate image file
            if not is_valid_image_file(profile_image):
                logger.warning(f"Invalid image file: {profile_image.filename}")
                raise HTTPException(
                    status_code=400,
                    detail="Invalid image file. Please upload a valid image (JPG, PNG, GIF, BMP, WebP).",
                )

            # Upload to Google Cloud Storage
            try:
                new_photo_url = await upload_profile_image_to_gcs(
                    profile_image, user_id
                )
                update_data["photo_url"] = new_photo_url
                logger.info(f"Profile image uploaded successfully: {new_photo_url}")
            except HTTPException:
                raise
            except Exception as upload_error:
                logger.error(f"Failed to upload profile image: {upload_error}")
                raise HTTPException(
                    status_code=500, detail="Failed to upload profile image"
                )

        # Handle display name update
        if display_name and display_name.strip():
            update_data["display_name"] = display_name.strip()
            logger.info(f"Updating display name to: {display_name.strip()}")

        # Check if there's anything to update
        if not update_data:
            raise HTTPException(
                status_code=400, detail="No valid data provided for update"
            )

        # Add updated timestamp
        update_data["updated_at"] = datetime.now()

        # Find and update user profile in Firestore
        try:
            profiles_ref = firestore_client.collection("profiles")
            query = profiles_ref.where(
                filter=FieldFilter("user_id", "==", user_id)
            ).limit(1)
            existing_profiles = list(query.stream())

            if not existing_profiles:
                logger.error(f"User profile not found for user_id: {user_id}")
                raise HTTPException(status_code=404, detail="User profile not found")

            # Update the profile
            profile_doc = existing_profiles[0]
            profile_doc.reference.update(update_data)

            # Get updated profile data
            updated_profile = profile_doc.reference.get().to_dict()

            logger.info(f"Profile updated successfully for user: {user_id}")

            return ProfileUpdateResponse(
                success=True,
                message="Profile updated successfully!",
                user_profile=updated_profile or {},
            )

        except HTTPException:
            raise
        except Exception as firestore_error:
            logger.error(f"Failed to update profile in Firestore: {firestore_error}")
            raise HTTPException(
                status_code=500, detail="Failed to update profile in database"
            )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating user profile: {str(e)}")
        raise HTTPException(
            status_code=500, detail=f"Failed to update profile: {str(e)}"
        )


@profile_router.get("/me")
async def get_user_profile(request: Request):
    """
    Get current user's profile information
    """
    try:
        user_id = get_user_id(request)
        logger.info(f"Getting profile for user: {user_id}")

        # Find user profile in Firestore
        profiles_ref = firestore_client.collection("profiles")
        query = profiles_ref.where(filter=FieldFilter("user_id", "==", user_id)).limit(
            1
        )
        existing_profiles = list(query.stream())

        if not existing_profiles:
            logger.error(f"User profile not found for user_id: {user_id}")
            raise HTTPException(status_code=404, detail="User profile not found")

        profile_data = existing_profiles[0].to_dict()

        logger.info(f"Profile retrieved successfully for user: {user_id}")

        return {"success": True, "user_profile": profile_data}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting user profile: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get profile: {str(e)}")
