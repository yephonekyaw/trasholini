from typing import Union
from fastapi import APIRouter, HTTPException as StarletteHTTPException, status
import time

test_router = APIRouter()


@test_router.get("/")
async def root():
    return {"message": "Greeting from the Trasholini FastAPI Server, ready to serve 🚀"}


@test_router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": time.time(),
        "services": {
            "api": "running",
            "websocket": "running",
            "waste_detection": "ready",
        },
    }
