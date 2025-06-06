from fastapi import Request
from starlette.exceptions import HTTPException as StarletteHTTPException


def get_user_id(request: Request) -> str:
    user_id = getattr(request.state, "user_id", None)
    print(user_id)
    if not user_id:
        raise StarletteHTTPException(status_code=401, detail="User ID required")
    return user_id
