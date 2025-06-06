from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from app.core.logging import logger
from typing import Callable


class UserIDMiddleware(BaseHTTPMiddleware):
    """
    Middleware to extract user ID from request headers and add to request state
    """

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Extract user ID from headers
        user_id = request.headers.get("X-User-ID")

        # Also check query parameters (for GET requests)
        if not user_id:
            user_id = request.query_params.get("user_id")

        # Also check form data or JSON body for POST requests
        if not user_id and request.method in ["POST", "PUT", "PATCH"]:
            try:
                # For JSON requests
                if request.headers.get("content-type") == "application/json":
                    # Note: We can't read the body here without consuming it
                    # So we'll rely on headers and query params
                    pass
            except Exception:
                pass

        # Store user ID in request state for easy access in endpoints
        request.state.user_id = user_id

        # Log the request with user info
        if user_id:
            logger.info(
                f"Request from user: {user_id} - {request.method} {request.url.path}"
            )
        else:
            logger.info(f"Anonymous request: {request.method} {request.url.path}")

        # Continue with the request
        response = await call_next(request)
        return response
