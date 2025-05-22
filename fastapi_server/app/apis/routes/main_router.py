from fastapi import APIRouter
from app.apis.routes import test_router

main_router = APIRouter()

main_router.include_router(test_router.test_router, prefix="/test")
