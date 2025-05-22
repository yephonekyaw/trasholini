import logging
import sys

from app.core.config import settings

# Configure logging levels
log_level = getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO)

# Configure root logger
logging.basicConfig(
    level=log_level,
    format="{asctime} - {name} - {levelname} - {message}",
    style="{",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[
        logging.StreamHandler(sys.stdout),
    ],
)

# Create app logger
logger = logging.getLogger("app")
logger.setLevel(log_level)
