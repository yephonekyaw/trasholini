from fastapi import APIRouter
from app.apis import (
    auth_router,
    test_router,
    bin_router,
    scan_router,
    history_router,
    profile_router,
    danger_router,
)

main_router = APIRouter()

main_router.include_router(test_router.test_router, prefix="/test")
main_router.include_router(auth_router.auth_router, prefix="/auth")
main_router.include_router(bin_router.bin_router, prefix="/bin")
main_router.include_router(scan_router.scan_router, prefix="/scan")
main_router.include_router(history_router.history_router, prefix="/disposal")
main_router.include_router(profile_router.profile_router, prefix="/profile")
main_router.include_router(danger_router.danger_router, prefix="/danger")
