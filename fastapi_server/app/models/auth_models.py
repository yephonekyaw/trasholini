from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional, Any, Union


class AuthRequest(BaseModel):
    google_id: str
    email: EmailStr
    display_name: Optional[str] = None
    photo_url: Optional[str] = None


class AuthResponse(BaseModel):
    user_id: Union[str, Any]
    email: Union[EmailStr, Any]
    display_name: Optional[str] = None
    photo_url: Optional[str] = None
    eco_points: Union[int, Any] = 0
    total_scans: Union[int, Any] = 0
    created_at: Union[datetime, Any]
    updated_at: Union[datetime, Any]
