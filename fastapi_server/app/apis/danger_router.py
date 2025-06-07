from fastapi import APIRouter, HTTPException, Request, Query
from typing import Dict, Any, List
from pydantic import BaseModel, field_validator
from app.utils.extract_user_id import get_user_id
from app.utils.firestore import firestore_client
from app.core.config import settings
from app.core.logging import logger
from google.cloud.firestore import FieldFilter
from datetime import datetime, timezone
import asyncio
from concurrent.futures import ThreadPoolExecutor
import traceback
from app.utils.storage import storage_client


danger_router = APIRouter()


class UserDeletionRequest(BaseModel):
    confirmation_text: str
    user_email: str  # Email for additional verification

    @field_validator("confirmation_text")
    @classmethod
    def validate_confirmation(cls, v):
        if v != "DELETE":
            raise ValueError("Confirmation text must be exactly: DELETE")
        return v


class UserDeletionResponse(BaseModel):
    success: bool
    message: str
    deleted_items: Dict[str, Any]
    errors: List[str]
    timestamp: str


class UserDeletionSummary(BaseModel):
    firestore_deletions: Dict[str, int]
    storage_deletions: Dict[str, int]
    total_files_deleted: int
    total_documents_deleted: int
    errors_encountered: List[str]


@danger_router.delete("/user/delete-all-data", response_model=UserDeletionResponse)
async def DELETE_user_data(
    deletion_request: UserDeletionRequest,
    request: Request,
    force_delete: bool = Query(
        False, description="DANGER: Force deletion even if some operations fail"
    ),
):
    """
    ⚠️  DANGER ZONE ⚠️

    PERMANENTLY DELETE ALL USER DATA

    This endpoint will irreversibly delete:
    - All Firestore documents (profiles, disposal-history, available-bins)
    - All Cloud Storage files (disposal-images/{user_id}/, profile-images/{user_id}/)

    ⚠️  THIS OPERATION CANNOT BE UNDONE ⚠️

    Required confirmation: "DELETE"
    """
    try:
        user_id = get_user_id(request)
        deletion_timestamp = datetime.now(timezone.utc).isoformat()

        logger.critical(
            f"🚨 DANGER: User deletion request initiated for user: {user_id}"
        )
        logger.critical(f"🚨 Confirmation: {deletion_request.confirmation_text}")
        logger.critical(f"🚨 Email verification: {deletion_request.user_email}")
        logger.critical(f"🚨 Force delete: {force_delete}")
        logger.critical(f"🚨 Timestamp: {deletion_timestamp}")

        # Initialize tracking variables
        deleted_items = {"firestore": {}, "cloud_storage": {}, "summary": {}}
        errors = []

        # Step 1: Verify user exists in profiles
        await _verify_user_exists(user_id, deletion_request.user_email)

        # Step 2: Delete Firestore documents
        logger.warning(f"Starting Firestore deletion for user: {user_id}")
        firestore_results = await _delete_firestore_data(user_id, force_delete)
        deleted_items["firestore"] = firestore_results["deleted"]
        errors.extend(firestore_results["errors"])

        # Step 3: Delete Cloud Storage files
        logger.warning(f"Starting Cloud Storage deletion for user: {user_id}")
        storage_results = await _delete_cloud_storage_data(user_id, force_delete)
        deleted_items["cloud_storage"] = storage_results["deleted"]
        errors.extend(storage_results["errors"])

        # Step 4: Calculate summary
        total_docs = sum(deleted_items["firestore"].values())
        total_files = sum(deleted_items["cloud_storage"].values())

        deleted_items["summary"] = {
            "total_documents_deleted": total_docs,
            "total_files_deleted": total_files,
            "deletion_timestamp": deletion_timestamp,
            "user_id": user_id,
            "force_delete_used": force_delete,
        }

        # Final logging
        logger.critical(f"🚨 DELETION COMPLETED for user: {user_id}")
        logger.critical(f"🚨 Documents deleted: {total_docs}")
        logger.critical(f"🚨 Files deleted: {total_files}")
        logger.critical(f"🚨 Errors encountered: {len(errors)}")

        # Determine success status
        has_critical_errors = len(errors) > 0 and not force_delete
        success = not has_critical_errors

        if not success:
            logger.error(f"User deletion failed for {user_id} due to errors: {errors}")

        return UserDeletionResponse(
            success=success,
            message=(
                f"✅ User data deletion completed successfully. "
                f"Deleted {total_docs} documents and {total_files} files."
                if success
                else f"❌ User data deletion completed with errors. "
                f"Use force_delete=true to ignore errors."
            ),
            deleted_items=deleted_items,
            errors=errors,
            timestamp=deletion_timestamp,
        )

    except HTTPException:
        raise
    except Exception as e:
        error_msg = f"Critical error during user deletion: {str(e)}"
        logger.critical(f"🚨 {error_msg}")
        logger.critical(f"🚨 Traceback: {traceback.format_exc()}")

        raise HTTPException(
            status_code=500, detail=f"User deletion failed: {error_msg}"
        )


async def _verify_user_exists(user_id: str, provided_email: str) -> None:
    """Verify user exists and email matches for additional security"""
    try:

        profiles_ref = firestore_client.collection("profiles")
        query = profiles_ref.where(filter=FieldFilter("user_id", "==", user_id)).limit(
            1
        )

        docs = list(query.stream())

        if not docs:
            logger.warning(f"User not found in profiles: {user_id}")
            raise HTTPException(
                status_code=404,
                detail="User not found. Cannot delete non-existent user data.",
            )

        user_doc = docs[0].to_dict()
        if not user_doc:
            logger.warning(f"User document data is empty for user: {user_id}")
            raise HTTPException(
                status_code=404,
                detail="User data not found. Cannot delete user with empty profile data.",
            )
        stored_email = user_doc.get("email", "").lower()
        provided_email_lower = provided_email.lower()

        if stored_email != provided_email_lower:
            logger.warning(
                f"Email mismatch for user {user_id}: "
                f"stored='{stored_email}' vs provided='{provided_email_lower}'"
            )
            raise HTTPException(
                status_code=403,
                detail="Email verification failed. Provided email does not match user record.",
            )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error verifying user: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to verify user: {str(e)}")


async def _delete_firestore_data(user_id: str, force_delete: bool) -> Dict[str, Any]:
    """Delete all Firestore documents for the user"""
    deleted_counts = {"profiles": 0, "disposal_history": 0, "available_bins": 0}
    errors = []

    try:
        # Delete from profiles collection
        try:
            profiles_ref = firestore_client.collection("profiles")
            query = profiles_ref.where(filter=FieldFilter("user_id", "==", user_id))

            docs = list(query.stream())
            for doc in docs:
                doc.reference.delete()
                deleted_counts["profiles"] += 1

        except Exception as e:
            error_msg = f"Error deleting profiles: {str(e)}"
            logger.error(error_msg)
            errors.append(error_msg)
            if not force_delete:
                raise

        # Delete from disposal-history collection
        try:
            disposal_ref = firestore_client.collection("disposal-history")
            query = disposal_ref.where(filter=FieldFilter("user_id", "==", user_id))

            docs = list(query.stream())
            for doc in docs:
                doc.reference.delete()
                deleted_counts["disposal_history"] += 1

        except Exception as e:
            error_msg = f"Error deleting disposal history: {str(e)}"
            logger.error(error_msg)
            errors.append(error_msg)
            if not force_delete:
                raise

        # Delete from available-bins collection
        try:
            bins_ref = firestore_client.collection("available-bins")
            user_bins_doc = bins_ref.document(user_id)

            if user_bins_doc.get().exists:
                user_bins_doc.delete()
                deleted_counts["available_bins"] += 1

        except Exception as e:
            error_msg = f"Error deleting available bins: {str(e)}"
            logger.error(error_msg)
            errors.append(error_msg)
            if not force_delete:
                raise

    except Exception as e:
        if not force_delete:
            raise
        errors.append(f"Critical Firestore error: {str(e)}")

    return {"deleted": deleted_counts, "errors": errors}


async def _delete_cloud_storage_data(
    user_id: str, force_delete: bool
) -> Dict[str, Any]:
    """Delete all Cloud Storage files for the user"""
    if not storage_client:
        error_msg = "Cloud Storage client not initialized"
        logger.error(error_msg)
        return {
            "deleted": {"disposal_images": 0, "profile_images": 0},
            "errors": [error_msg] if not force_delete else [],
        }

    deleted_counts = {"disposal_images": 0, "profile_images": 0}
    errors = []

    try:
        bucket = storage_client.bucket(settings.GCS_BUCKET_NAME)

        # Delete disposal images
        try:
            disposal_prefix = f"disposal-images/{user_id}/"
            disposal_count = await _delete_storage_folder(bucket, disposal_prefix)
            deleted_counts["disposal_images"] = disposal_count

        except Exception as e:
            error_msg = f"Error deleting disposal images: {str(e)}"
            logger.error(error_msg)
            errors.append(error_msg)
            if not force_delete:
                raise

        # Delete profile images
        try:
            profile_prefix = f"profile-images/{user_id}/"
            profile_count = await _delete_storage_folder(bucket, profile_prefix)
            deleted_counts["profile_images"] = profile_count

        except Exception as e:
            error_msg = f"Error deleting profile images: {str(e)}"
            logger.error(error_msg)
            errors.append(error_msg)
            if not force_delete:
                raise

    except Exception as e:
        if not force_delete:
            raise
        errors.append(f"Critical Cloud Storage error: {str(e)}")

    return {"deleted": deleted_counts, "errors": errors}


async def _delete_storage_folder(bucket, prefix: str) -> int:
    """Delete all files in a Cloud Storage folder"""

    def _delete_blobs():
        deleted_count = 0
        try:
            blobs = list(bucket.list_blobs(prefix=prefix))

            for blob in blobs:
                try:
                    blob.delete()
                    deleted_count += 1
                    logger.debug(f"Deleted blob: {blob.name}")
                except Exception as e:
                    logger.warning(f"Failed to delete blob {blob.name}: {e}")

        except Exception as e:
            logger.error(f"Error listing blobs with prefix {prefix}: {e}")
            raise

        return deleted_count

    # Run in thread pool to avoid blocking
    loop = asyncio.get_event_loop()
    with ThreadPoolExecutor() as executor:
        deleted_count = await loop.run_in_executor(executor, _delete_blobs)

    return deleted_count


@danger_router.get("/user/deletion-preview")
async def preview_user_deletion(request: Request):
    """
    Preview what data would be deleted for the current user
    (Safe operation - does not delete anything)
    """
    try:
        user_id = get_user_id(request)

        preview_data = {
            "user_id": user_id,
            "firestore_collections": {},
            "cloud_storage_folders": {},
            "estimated_total_items": 0,
        }

        # Count Firestore documents
        try:
            # Count profiles
            profiles_ref = firestore_client.collection("profiles")
            profiles_query = profiles_ref.where(
                filter=FieldFilter("user_id", "==", user_id)
            )
            profiles_count = len(list(profiles_query.stream()))
            preview_data["firestore_collections"]["profiles"] = profiles_count

            # Count disposal history
            disposal_ref = firestore_client.collection("disposal-history")
            disposal_query = disposal_ref.where(
                filter=FieldFilter("user_id", "==", user_id)
            )
            disposal_count = len(list(disposal_query.stream()))
            preview_data["firestore_collections"]["disposal_history"] = disposal_count

            # Count available bins
            bins_ref = firestore_client.collection("available-bins")
            bins_doc = bins_ref.document(user_id)
            bins_count = 1 if bins_doc.get().exists else 0
            preview_data["firestore_collections"]["available_bins"] = bins_count

        except Exception as e:
            logger.warning(f"Error counting Firestore documents: {e}")
            preview_data["firestore_collections"]["error"] = str(e)

        # Count Cloud Storage files
        if storage_client:
            try:
                bucket = storage_client.bucket(settings.GCS_BUCKET_NAME)

                # Count disposal images
                disposal_blobs = list(
                    bucket.list_blobs(prefix=f"disposal-images/{user_id}/")
                )
                preview_data["cloud_storage_folders"]["disposal_images"] = len(
                    disposal_blobs
                )

                # Count profile images
                profile_blobs = list(
                    bucket.list_blobs(prefix=f"profile-images/{user_id}/")
                )
                preview_data["cloud_storage_folders"]["profile_images"] = len(
                    profile_blobs
                )

            except Exception as e:
                logger.warning(f"Error counting Cloud Storage files: {e}")
                preview_data["cloud_storage_folders"]["error"] = str(e)
        else:
            preview_data["cloud_storage_folders"][
                "error"
            ] = "Storage client not available"

        # Calculate total
        firestore_total = sum(
            v
            for v in preview_data["firestore_collections"].values()
            if isinstance(v, int)
        )
        storage_total = sum(
            v
            for v in preview_data["cloud_storage_folders"].values()
            if isinstance(v, int)
        )
        preview_data["estimated_total_items"] = firestore_total + storage_total

        return {
            "success": True,
            "preview": preview_data,
            "warning": "⚠️  The actual deletion will permanently remove all this data ⚠️",
            "required_confirmation": "DELETE",
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error generating deletion preview: {e}")
        raise HTTPException(
            status_code=500, detail=f"Failed to generate deletion preview: {str(e)}"
        )
