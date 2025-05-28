from fastapi import APIRouter
from app.apis.routes import auth_router, test_router

main_router = APIRouter()

main_router.include_router(test_router.test_router, prefix="/test")
main_router.include_router(auth_router.auth_router, prefix="/auth")
