import time
import uuid
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
import app.core.errors as _
from app.apis.routes import api_router
from app.apis.routes.websocket_router import websocket_router
from app.core.config import settings
from app.core.logging import logger
from app.middlewares.user_id_middleware import UserIDMiddleware
from typing import Callable, Awaitable


@asynccontextmanager
async def lifespan(_: FastAPI):
    """Startup and shutdown events."""
    logger.info("Application starting up...")
    yield
    logger.info("Application shutting down...")


def create_application() -> FastAPI:
    """Create FastAPI application with middleware and routes."""
    application = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        lifespan=lifespan,
    )

    # Add CORS middleware
    application.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Add user ID middleware
    application.add_middleware(UserIDMiddleware)

    # Request ID middleware
    @application.middleware("http")
    async def add_request_id_middleware(
        request: Request, call_next: Callable[[Request], Awaitable[Response]]
    ):
        request_id = str(uuid.uuid4())
        request.state.request_id = request_id

        # Record request start time
        start_time = time.time()

        # Log request
        logger.info(
            f"Request started: {request.method} {request.url.path} (ID: {request_id})"
        )

        # Process request
        try:
            response = await call_next(request)

            # Log request completion
            process_time = time.time() - start_time
            logger.info(
                f"Request completed: {request.method} {request.url.path} "
                f"(ID: {request_id}, Status: {response.status_code}, "
                f"Time: {process_time:.3f}s)"
            )

            # Add request ID to response headers
            response.headers["X-Request-ID"] = request_id
            return response
        except Exception as e:
            # Log error and re-raise
            logger.error(
                f"Request failed: {request.method} {request.url.path} "
                f"(ID: {request_id}, Error: {str(e)})",
                exc_info=True,
            )
            raise

    # Add security headers middleware
    @application.middleware("http")
    async def add_security_headers_middleware(
        request: Request, call_next: Callable[[Request], Awaitable[Response]]
    ):
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = "no-referrer"
        response.headers["Permissions-Policy"] = "geolocation=(self), microphone=()"
        response.headers["Content-Security-Policy"] = (
            "default-src 'self';"
            "script-src 'self';"
            "style-src 'self';"
            "img-src 'self' data:;"
            "connect-src 'self' ws: wss:"
        )

        return response

    application.include_router(api_router, prefix=settings.APP_API_PREFIX)
    application.include_router(websocket_router, prefix=settings.APP_WEB_SOCKET_PREFIX)

    return application


app = create_application()


@app.get("/")
async def root():
    return {"message": "Welcome to the FastAPI application!"}


@app.get("/health")
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


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="localhost",
        port=8000,
        reload=True,
    )
