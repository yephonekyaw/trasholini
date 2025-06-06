from fastapi import APIRouter
from app.apis.routes import auth_router, test_router, bin_router, scan_router

main_router = APIRouter()

main_router.include_router(test_router.test_router, prefix="/test")
main_router.include_router(auth_router.auth_router, prefix="/auth")
main_router.include_router(bin_router.bin_router, prefix="/bin")
main_router.include_router(scan_router.scan_router, prefix="/scan")
