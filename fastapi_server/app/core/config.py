from typing import List, Union
from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_NAME: str = ""
    APP_VERSION: str = ""
    APP_API_PREFIX: str = ""
    APP_WEB_SOCKET_PREFIX: str = ""
    SECRET_KEY: str = ""
    ALGORITHM: str = ""
    """Pydantic v2 doesn't support parsing List[str] from a plain comma-separated string by default anymore."""
    ALLOWED_HOSTS: Union[str, List[str]] = ""
    LOG_LEVEL: str = ""
    GOOGLE_FIREBASE_CREDENTIALS: str = ""
    GOOGLE_STORAGE_CREDENTIALS: str = ""
    ROBOFLOW_MODEL_URL: str = ""
    ROBOFLOW_API_KEY: str = ""
    ROBOFLOW_MODEL_ID: str = ""
    GEMINI_API_KEY: str = ""
    GCS_BUCKET_NAME: str = ""
    ENVIRONMENT: str = "development"

    @field_validator("ALLOWED_HOSTS", mode="before")
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        if not v:
            return []
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        return v

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )


settings = Settings()
