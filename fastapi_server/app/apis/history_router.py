from fastapi import APIRouter, HTTPException, Request, Query, Path
from typing import List, Dict, Any, Optional
from pydantic import BaseModel, validator
from app.utils.extract_user_id import get_user_id
from app.utils.firestore import firestore_client
from app.core.logging import logger
from google.cloud.firestore import FieldFilter
from datetime import datetime


history_router = APIRouter()


class RecommendedBin(BaseModel):
    description: str
    id: str
    name: str


class DisposalHistoryItem(BaseModel):
    id: str
    confidence: float
    disposal_tips: str
    environmental_note: str
    image_url: str
    preparation_steps: str
    recommended_bin: Optional[RecommendedBin] = None
    saved_at: str
    user_id: str
    waste_class: str


class DisposalHistoryResponse(BaseModel):
    success: bool
    history: List[DisposalHistoryItem]
    count: int
    message: str


class DeleteResponse(BaseModel):
    success: bool
    message: str
    deleted_item_id: str


class DateRangeRequest(BaseModel):
    start_date: str
    end_date: str

    @validator("start_date", "end_date")
    def validate_datetime_format(cls, v):
        try:
            # Try to parse the datetime string
            datetime.fromisoformat(v.replace("Z", "+00:00"))
            return v
        except ValueError:
            raise ValueError(
                "DateTime must be in ISO format (e.g., 2024-01-01T00:00:00Z)"
            )


@history_router.get("/history", response_model=DisposalHistoryResponse)
async def get_disposal_history(
    request: Request,
    waste_class: Optional[str] = Query(None, description="Filter by waste class"),
    limit: int = Query(
        50, ge=1, le=100, description="Maximum number of records to return"
    ),
):
    """
    Get user's disposal history filtered by waste_class
    Returns disposal history excluding created_at, image_filename, and message fields
    """
    try:
        user_id = get_user_id(request)

        # Start building the query
        disposal_collection = firestore_client.collection("disposal-history")

        # Base query with user filter
        query = disposal_collection.where(filter=FieldFilter("user_id", "==", user_id))

        # Add waste_class filter if provided
        if waste_class:
            query = query.where(
                filter=FieldFilter("waste_class", "==", waste_class.lower())
            )

        # Order by saved_at descending and apply limit
        query = query.order_by("saved_at", direction="DESCENDING").limit(limit)

        # Execute query
        docs = query.stream()

        history = []
        for doc in docs:
            try:
                doc_data = doc.to_dict()

                if doc_data is None:
                    logger.warning(f"Document {doc.id} has no data")
                    continue

                # Create the filtered response object excluding specified fields
                filtered_data = {
                    "id": doc.id,
                    "confidence": doc_data.get("confidence", 0.0),
                    "disposal_tips": doc_data.get("disposal_tips", ""),
                    "environmental_note": doc_data.get("environmental_note", ""),
                    "image_url": doc_data.get("image_url", ""),
                    "preparation_steps": doc_data.get("preparation_steps", ""),
                    "saved_at": doc_data.get("saved_at", ""),
                    "user_id": doc_data.get("user_id", ""),
                    "waste_class": doc_data.get("waste_class", ""),
                }

                # Handle recommended_bin object
                recommended_bin_data = doc_data.get("recommended_bin")
                if recommended_bin_data and isinstance(recommended_bin_data, dict):
                    try:
                        filtered_data["recommended_bin"] = RecommendedBin(
                            description=recommended_bin_data.get("description", ""),
                            id=recommended_bin_data.get("id", ""),
                            name=recommended_bin_data.get("name", ""),
                        )
                    except Exception as bin_error:
                        logger.warning(
                            f"Error processing recommended_bin for doc {doc.id}: {bin_error}"
                        )
                        filtered_data["recommended_bin"] = None
                else:
                    filtered_data["recommended_bin"] = None

                # Create and validate the response item
                disposal_item = DisposalHistoryItem(**filtered_data)
                history.append(disposal_item)

                logger.debug(f"Successfully processed disposal record: {doc.id}")

            except Exception as doc_error:
                logger.error(f"Error processing document {doc.id}: {str(doc_error)}")
                continue

        # Create response message
        filter_msg = f" for waste class '{waste_class}'" if waste_class else ""
        message = f"Retrieved {len(history)} disposal records{filter_msg}"

        return DisposalHistoryResponse(
            success=True, history=history, count=len(history), message=message
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting disposal history: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500, detail=f"Failed to retrieve disposal history: {str(e)}"
        )


@history_router.delete("/history/{item_id}", response_model=DeleteResponse)
async def delete_disposal_item(
    request: Request,
    item_id: str = Path(..., description="The ID of the disposal item to delete"),
):
    """
    Delete a specific disposal history item by ID

    The item can only be deleted by the user who created it (security check)

    Parameters:
    - item_id: The document ID of the disposal history item to delete

    Returns:
    - success: Boolean indicating if deletion was successful
    - message: Descriptive message about the operation
    - deleted_item_id: The ID of the deleted item
    """
    try:
        user_id = get_user_id(request)

        # Get reference to the document
        disposal_collection = firestore_client.collection("disposal-history")
        doc_ref = disposal_collection.document(item_id)

        # Check if document exists and get its data
        doc = doc_ref.get()

        if not doc.exists:
            logger.warning(f"Disposal item {item_id} not found")
            raise HTTPException(
                status_code=404, detail=f"Disposal item with ID '{item_id}' not found"
            )

        # Get document data for security check
        doc_data = doc.to_dict()

        if doc_data is None:
            logger.error(f"Document {item_id} exists but has no data")
            raise HTTPException(
                status_code=500, detail="Document exists but has no data"
            )

        # Security check: Ensure the item belongs to the authenticated user
        doc_user_id = doc_data.get("user_id")

        if doc_user_id != user_id:
            logger.warning(
                f"User {user_id} attempted to delete item {item_id} "
                f"belonging to user {doc_user_id}"
            )
            raise HTTPException(
                status_code=403, detail="You can only delete your own disposal items"
            )

        # Get waste_class for logging purposes
        waste_class = doc_data.get("waste_class", "unknown")

        # Delete the document
        doc_ref.delete()

        return DeleteResponse(
            success=True,
            message=f"Disposal item '{waste_class}' deleted successfully",
            deleted_item_id=item_id,
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting disposal item {item_id}: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500, detail=f"Failed to delete disposal item: {str(e)}"
        )


@history_router.get("/date-range", response_model=DisposalHistoryResponse)
async def get_disposal_history_by_date_range(
    request: Request,
    start_date: str = Query(
        ..., description="Start date in ISO format (e.g., 2024-01-01T00:00:00Z)"
    ),
    end_date: str = Query(
        ..., description="End date in ISO format (e.g., 2024-01-31T23:59:59Z)"
    ),
    waste_class: Optional[str] = Query(None, description="Filter by waste class"),
    limit: int = Query(
        100, ge=1, le=500, description="Maximum number of records to return"
    ),
):
    """
    Get user's disposal history within a specific date range

    Parameters:
    - start_date: Start date in ISO format (inclusive)
    - end_date: End date in ISO format (inclusive)
    - waste_class: Optional filter by waste class
    - limit: Maximum number of records to return

    Example usage:
    - Last week: start_date=2024-01-01T00:00:00Z, end_date=2024-01-07T23:59:59Z
    - Last month: start_date=2024-01-01T00:00:00Z, end_date=2024-01-31T23:59:59Z
    """
    try:
        user_id = get_user_id(request)

        # Validate and parse dates
        try:
            # Parse start_date
            start_dt = datetime.fromisoformat(start_date.replace("Z", "+00:00"))
            # Parse end_date
            end_dt = datetime.fromisoformat(end_date.replace("Z", "+00:00"))

            # Validate date range
            if start_dt >= end_dt:
                raise HTTPException(
                    status_code=400, detail="start_date must be before end_date"
                )

            # Convert back to ISO strings for Firestore comparison
            start_iso = start_dt.isoformat()
            end_iso = end_dt.isoformat()

        except ValueError as date_error:
            logger.error(f"Invalid date format: {date_error}")
            raise HTTPException(
                status_code=400,
                detail="Invalid date format. Use ISO format like: 2024-01-01T00:00:00Z",
            )

        # Start building the query
        disposal_collection = firestore_client.collection("disposal-history")

        # Base query with user filter
        query = disposal_collection.where(filter=FieldFilter("user_id", "==", user_id))

        # Add date range filters
        # Note: Firestore requires range queries to be ordered by the same field
        query = query.where(filter=FieldFilter("saved_at", ">=", start_iso))
        query = query.where(filter=FieldFilter("saved_at", "<=", end_iso))

        # Add waste_class filter if provided
        if waste_class:
            query = query.where(
                filter=FieldFilter("waste_class", "==", waste_class.lower())
            )

        # Order by saved_at descending and apply limit
        query = query.order_by("saved_at", direction="DESCENDING").limit(limit)

        # Execute query
        docs = query.stream()

        history = []
        for doc in docs:
            try:
                doc_data = doc.to_dict()

                if doc_data is None:
                    logger.warning(f"Document {doc.id} has no data")
                    continue

                # Create the filtered response object
                filtered_data = {
                    "id": doc.id,
                    "confidence": doc_data.get("confidence", 0.0),
                    "disposal_tips": doc_data.get("disposal_tips", ""),
                    "environmental_note": doc_data.get("environmental_note", ""),
                    "image_url": doc_data.get("image_url", ""),
                    "preparation_steps": doc_data.get("preparation_steps", ""),
                    "saved_at": doc_data.get("saved_at", ""),
                    "user_id": doc_data.get("user_id", ""),
                    "waste_class": doc_data.get("waste_class", ""),
                }

                # Handle recommended_bin object
                recommended_bin_data = doc_data.get("recommended_bin")
                if recommended_bin_data and isinstance(recommended_bin_data, dict):
                    try:
                        filtered_data["recommended_bin"] = RecommendedBin(
                            description=recommended_bin_data.get("description", ""),
                            id=recommended_bin_data.get("id", ""),
                            name=recommended_bin_data.get("name", ""),
                        )
                    except Exception as bin_error:
                        logger.warning(
                            f"Error processing recommended_bin for doc {doc.id}: {bin_error}"
                        )
                        filtered_data["recommended_bin"] = None
                else:
                    filtered_data["recommended_bin"] = None

                # Create and validate the response item
                disposal_item = DisposalHistoryItem(**filtered_data)
                history.append(disposal_item)

                logger.debug(f"Successfully processed disposal record: {doc.id}")

            except Exception as doc_error:
                logger.error(f"Error processing document {doc.id}: {str(doc_error)}")
                continue

        # Calculate the date range for the message
        start_date_str = start_dt.strftime("%Y-%m-%d")
        end_date_str = end_dt.strftime("%Y-%m-%d")

        # Create response message
        filter_msg = f" for waste class '{waste_class}'" if waste_class else ""
        date_msg = f" between {start_date_str} and {end_date_str}"
        message = f"Retrieved {len(history)} disposal records{date_msg}{filter_msg}"

        return DisposalHistoryResponse(
            success=True, history=history, count=len(history), message=message
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            f"Error getting disposal history by date range: {str(e)}", exc_info=True
        )
        raise HTTPException(
            status_code=500,
            detail=f"Failed to retrieve disposal history by date range: {str(e)}",
        )


@history_router.get("/waste-classes", response_model=Dict[str, Any])
async def get_user_waste_classes(request: Request):
    """
    Get all unique waste classes from user's disposal history
    """
    try:
        user_id = get_user_id(request)

        # Query all disposal records for the user
        disposal_collection = firestore_client.collection("disposal-history")
        query = disposal_collection.where(filter=FieldFilter("user_id", "==", user_id))

        docs = query.stream()

        waste_classes = set()
        total_records = 0

        for doc in docs:
            try:
                doc_data = doc.to_dict()
                if doc_data and "waste_class" in doc_data:
                    waste_classes.add(doc_data["waste_class"])
                    total_records += 1
            except Exception as doc_error:
                logger.warning(f"Error processing document {doc.id}: {doc_error}")
                continue

        waste_classes_list = sorted(list(waste_classes))

        return {
            "success": True,
            "waste_classes": waste_classes_list,
            "count": len(waste_classes_list),
            "total_records": total_records,
            "message": f"Found {len(waste_classes_list)} unique waste classes",
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting waste classes: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to retrieve waste classes")
