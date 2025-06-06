from fastapi import APIRouter
from app.apis import main_router

api_router = APIRouter()
api_router.include_router(main_router.main_router, prefix="")
