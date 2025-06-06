from fastapi import APIRouter, HTTPException, Request
from typing import List, Dict, Any
from pydantic import BaseModel
from app.utils.extract_user_id import get_user_id
from app.utils.firestore import firestore_client
from datetime import datetime
from app.core.logging import logger

bin_router = APIRouter()


class UpdateBinListRequest(BaseModel):
    bin_ids: List[str]
    updated_at: str = ""


class AvailableBin(BaseModel):
    id: str
    name: str
    description: str
    color: str
    image_path: str


def convert_flutter_color_to_hex(flutter_color: str) -> str:
    """
    Convert Flutter color format (0xFFFFEB3B) to hex format (#FFEB3B)
    """
    try:
        if flutter_color.startswith("0x"):
            # Remove '0x' prefix and take last 6 characters (RGB part)
            hex_color = flutter_color[4:]  # Remove '0xFF'
            return f"#{hex_color}"
        elif flutter_color.startswith("#"):
            return flutter_color
        else:
            # Default color if format is unrecognized
            return "#616161"
    except Exception as e:
        logger.warning(f"Error converting color '{flutter_color}': {e}")
        return "#616161"


@bin_router.get("/available", response_model=Dict[str, List[AvailableBin]])
async def get_all_available_bins():
    """
    Endpoint 1: Get all available bin types from Firestore
    Uses Firestore document ID as the bin ID - much simpler!
    """
    try:
        logger.info("Getting all available bins from Firestore")

        # Get all documents from 'bins' collection
        bins_collection = firestore_client.collection("bins")
        docs = bins_collection.get()

        available_bins = []

        for doc in docs:
            try:
                bin_data = doc.to_dict()

                # Use Firestore document ID as bin ID
                bin_id = doc.id

                # Skip if document has no data
                if bin_data is None:
                    logger.warning(f"Bin document {bin_id} has no data")
                    continue

                # Check for required fields (no need for 'id' field anymore)
                required_fields = ["name", "description", "color", "imagePath"]
                missing_fields = [
                    field for field in required_fields if field not in bin_data
                ]

                if missing_fields:
                    logger.warning(
                        f"Bin document {bin_id} missing required fields: {missing_fields}"
                    )
                    continue

                # Convert Flutter color format to hex
                color_hex = convert_flutter_color_to_hex(bin_data["color"])

                # Create AvailableBin object using document ID
                available_bin = AvailableBin(
                    id=bin_id,  # Use Firestore document ID
                    name=bin_data["name"],
                    description=bin_data["description"],
                    color=color_hex,
                    image_path=bin_data["imagePath"],
                )

                available_bins.append(available_bin)
                logger.debug(f"Successfully added bin: {bin_id} - {available_bin.name}")

            except Exception as doc_error:
                logger.error(
                    f"Error processing bin document {doc.id}: {str(doc_error)}"
                )
                continue

        if not available_bins:
            logger.warning("No valid bins found in Firestore collection")
            return {"bins": []}

        # Sort bins by ID for consistent ordering
        available_bins.sort(key=lambda x: x.id)

        logger.info(
            f"Successfully retrieved {len(available_bins)} available bins from Firestore"
        )
        return {"bins": available_bins}

    except Exception as e:
        logger.error(f"Error getting available bins from Firestore: {str(e)}")
        raise HTTPException(
            status_code=500, detail=f"Failed to retrieve available bins: {str(e)}"
        )


@bin_router.get("/user-bins", response_model=Dict[str, List[str]])
async def get_bins_user_has_access_to(request: Request):
    """
    Endpoint 2: Get bins that user has access to
    Returns list of Firestore document IDs that the user has selected
    """
    try:
        user_id = get_user_id(request)
        logger.info(f"Getting accessible bins for user: {user_id}")

        # Get user's bin document from Firestore
        doc_ref = firestore_client.collection("available-bins").document(user_id)
        doc = doc_ref.get()

        if not doc.exists:
            logger.info(
                f"No bin preferences found for user {user_id}, returning empty list"
            )
            return {"accessible_bin_ids": []}

        doc_data = doc.to_dict()
        if doc_data is None:
            logger.warning(f"Document data is None for user {user_id}")
            return {"accessible_bin_ids": []}

        accessible_bins = doc_data.get("bin_ids", [])

        # Validate that the bin IDs exist as Firestore documents
        validated_bins = await _validate_bin_document_ids(accessible_bins)

        # Update user's document if some bins were invalid
        if len(validated_bins) != len(accessible_bins):
            logger.info(f"Removing invalid bin IDs for user {user_id}")
            doc_ref.update(
                {
                    "bin_ids": validated_bins,
                    "last_validated": datetime.now().isoformat(),
                }
            )

        logger.info(
            f"User {user_id} has access to {len(validated_bins)} bins: {validated_bins}"
        )
        return {"accessible_bin_ids": validated_bins}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting user accessible bins: {str(e)}")
        raise HTTPException(
            status_code=500, detail="Failed to retrieve user accessible bins"
        )


@bin_router.put("/user-bins", response_model=Dict[str, Any])
async def allow_user_update_their_bin_list(
    bin_data: UpdateBinListRequest, request: Request
):
    """
    Endpoint 3: Allow user to update their bin list
    Updates the list of Firestore document IDs that the user has access to
    """
    try:
        user_id = get_user_id(request)
        logger.info(f"Updating bin list for user {user_id}: {bin_data.bin_ids}")

        # Validate bin IDs as existing Firestore documents
        validated_bins = await _validate_bin_document_ids(bin_data.bin_ids)

        if len(validated_bins) != len(bin_data.bin_ids):
            invalid_bins = set(bin_data.bin_ids) - set(validated_bins)
            raise HTTPException(
                status_code=400,
                detail=f"Invalid bin IDs: {list(invalid_bins)}. These bins don't exist in the system.",
            )

        # Prepare document data
        doc_data = {
            "user_id": user_id,
            "bin_ids": validated_bins,
            "updated_at": bin_data.updated_at or datetime.now().isoformat(),
            "last_modified": datetime.now().isoformat(),
        }

        # Check if document exists
        doc_ref = firestore_client.collection("available-bins").document(user_id)
        doc = doc_ref.get()

        if doc.exists:
            # Update existing document
            doc_ref.update(doc_data)
            logger.info(f"Updated existing bin list for user {user_id}")
        else:
            # Create new document with created_at timestamp
            doc_data["created_at"] = datetime.now().isoformat()
            doc_ref.set(doc_data)
            logger.info(f"Created new bin list for user {user_id}")

        return {
            "success": True,
            "message": "Bin list updated successfully",
            "user_id": user_id,
            "bin_ids": validated_bins,
            "updated_at": doc_data["updated_at"],
            "total_bins": len(validated_bins),
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating user bin list: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to update bin list")


async def _validate_bin_document_ids(bin_ids: List[str]) -> List[str]:
    """
    Helper function to validate bin IDs as existing Firestore document IDs
    Much simpler - just check if documents exist!
    """
    try:
        if not bin_ids:
            return []

        bins_collection = firestore_client.collection("bins")
        validated_bins = []

        for bin_id in bin_ids:
            # Check if document exists
            doc_ref = bins_collection.document(bin_id)
            if doc_ref.get().exists:
                validated_bins.append(bin_id)
            else:
                logger.warning(f"Bin document '{bin_id}' does not exist")

        logger.debug(f"Validated {len(validated_bins)} out of {len(bin_ids)} bin IDs")
        return validated_bins

    except Exception as e:
        logger.error(f"Error validating bin document IDs: {str(e)}")
        return []
