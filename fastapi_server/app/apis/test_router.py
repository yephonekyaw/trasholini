from typing import Union
from fastapi import APIRouter, HTTPException as StarletteHTTPException, status
from app.core.logging import logger

test_router = APIRouter()


@test_router.get("/health", tags=["health"])
async def health_check():
    """Health check endpoint."""
    logger.info("Health check endpoint called")
    return {"status": "healthy"}


@test_router.get("/items/{item_id}", tags=["items"])
async def read_item(item_id: int) -> dict[str, Union[str, int]]:
    """Get an item by ID."""
    logger.info(f"Getting item with ID: {item_id}")

    # Example error handling
    if item_id <= 0:
        logger.warning(f"Invalid item ID requested: {item_id}")
        raise StarletteHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Item ID must be positive",
        )

    # In a real app, you would fetch from a database
    return {"id": item_id, "name": f"Example Item {item_id}"}
