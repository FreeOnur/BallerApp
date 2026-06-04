import hashlib
import secrets
from datetime import datetime, timedelta, timezone
from typing import Any
from uuid import UUID

from jose import JWTError, jwt

from app.config import settings

ALGORITHM = "HS256"


def create_access_token(user_id: UUID, email: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.jwt_access_minutes)
    payload = {"sub": str(user_id), "email": email, "exp": expire, "type": "access"}
    return jwt.encode(payload, settings.jwt_secret, algorithm=ALGORITHM)


def decode_access_token(token: str) -> dict[str, Any]:
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=[ALGORITHM])
        if payload.get("type") != "access":
            raise JWTError("invalid token type")
        return payload
    except JWTError as e:
        raise ValueError("invalid token") from e


def generate_refresh_token() -> str:
    return secrets.token_urlsafe(48)


def hash_refresh_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def refresh_expires_at() -> datetime:
    return datetime.now(timezone.utc) + timedelta(days=settings.jwt_refresh_days)
