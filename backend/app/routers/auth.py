from uuid import UUID, uuid4

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr, Field

from app.db import get_conn
from app.security.jwt import (
    create_access_token,
    generate_refresh_token,
    hash_refresh_token,
    refresh_expires_at,
)
from app.security.passwords import hash_password, verify_password

router = APIRouter(prefix="/auth", tags=["auth"])


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user_id: str


class RefreshRequest(BaseModel):
    refresh_token: str


@router.post("/register", response_model=TokenResponse)
def register(body: RegisterRequest) -> TokenResponse:
    user_id = uuid4()
    password_hash = hash_password(body.password)
    refresh_plain = generate_refresh_token()
    refresh_hash = hash_refresh_token(refresh_plain)

    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT id FROM users WHERE email = %s", (str(body.email),))
        if cur.fetchone():
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")

        cur.execute(
            "INSERT INTO users (id, email, password_hash) VALUES (%s, %s, %s)",
            (str(user_id), str(body.email), password_hash),
        )
        cur.execute(
            "INSERT INTO profiles (id, username) VALUES (%s, %s)",
            (str(user_id), ""),
        )
        cur.execute(
            "INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (%s, %s, %s)",
            (str(user_id), refresh_hash, refresh_expires_at()),
        )

    access = create_access_token(user_id, str(body.email))
    return TokenResponse(
        access_token=access,
        refresh_token=refresh_plain,
        user_id=str(user_id),
    )


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest) -> TokenResponse:
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(
            "SELECT id, email, password_hash FROM users WHERE email = %s",
            (str(body.email),),
        )
        row = cur.fetchone()
        if row is None or not verify_password(body.password, row["password_hash"]):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

        user_id = UUID(str(row["id"]))
        email = row["email"]
        refresh_plain = generate_refresh_token()
        refresh_hash = hash_refresh_token(refresh_plain)
        cur.execute(
            "INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (%s, %s, %s)",
            (str(user_id), refresh_hash, refresh_expires_at()),
        )

    access = create_access_token(user_id, email)
    return TokenResponse(
        access_token=access,
        refresh_token=refresh_plain,
        user_id=str(user_id),
    )


@router.post("/refresh", response_model=TokenResponse)
def refresh(body: RefreshRequest) -> TokenResponse:
    token_hash = hash_refresh_token(body.refresh_token)
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(
            """
            SELECT rt.user_id, u.email
            FROM refresh_tokens rt
            JOIN users u ON u.id = rt.user_id
            WHERE rt.token_hash = %s AND rt.expires_at > NOW()
            """,
            (token_hash,),
        )
        row = cur.fetchone()
        if row is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")

        user_id = UUID(str(row["user_id"]))
        email = row["email"]
        cur.execute("DELETE FROM refresh_tokens WHERE token_hash = %s", (token_hash,))
        refresh_plain = generate_refresh_token()
        new_hash = hash_refresh_token(refresh_plain)
        cur.execute(
            "INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (%s, %s, %s)",
            (str(user_id), new_hash, refresh_expires_at()),
        )

    access = create_access_token(user_id, email)
    return TokenResponse(
        access_token=access,
        refresh_token=refresh_plain,
        user_id=str(user_id),
    )


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(body: RefreshRequest) -> None:
    token_hash = hash_refresh_token(body.refresh_token)
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("DELETE FROM refresh_tokens WHERE token_hash = %s", (token_hash,))
