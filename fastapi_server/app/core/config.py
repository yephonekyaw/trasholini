from typing import List, Union
from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_NAME: str = "Trasholini FastAPI Server"
    APP_VERSION: str = "1.0.0"
    APP_API_PREFIX: str = "/api/v1"

    SECRET_KEY: str = "your-secret-key"
    ALGORITHM: str = "HS256"

    """Pydantic v2 (which you're using via pydantic-settings) doesn't support parsing List[str] from a plain comma-separated string by default anymore."""
    ALLOWED_HOSTS: Union[str, List[str]] = ""

    LOG_LEVEL: str = "info"

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
