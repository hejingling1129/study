import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
EXPORT_DIR = BASE_DIR / "exports"
EXPORT_DIR.mkdir(exist_ok=True)

HOST = os.getenv("HOST", "127.0.0.1")
PORT = int(os.getenv("PORT", "8000"))
BASE_URL = os.getenv("BASE_URL", f"http://{HOST}:{PORT}")

TELEAGENT_BASE_URL = os.getenv("TELEAGENT_BASE_URL", "")
TELEAGENT_API_KEY = os.getenv("TELEAGENT_API_KEY", "")
USE_MOCK_AI = os.getenv("USE_MOCK_AI", "true").lower() != "false"
