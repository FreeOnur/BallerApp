from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from app.db import get_conn
from app.dependencies import get_current_user_id

router = APIRouter(prefix="/profiles", tags=["profiles"])


class ProfileUpdate(BaseModel):
    username: str | None = None
    avatar_url: str | None = None
    age: int | None = None
    location: int | None = None
    gender: int | None = None
    skill_level: int | None = None


@router.get("/me")
def get_my_profile(user_id: Annotated[UUID, Depends(get_current_user_id)]) -> dict[str, Any]:
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM profiles WHERE id = %s", (str(user_id),))
        row = cur.fetchone()
        if row is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found")
        return dict(row)


@router.put("/me")
def upsert_my_profile(
    body: ProfileUpdate,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
) -> dict[str, Any]:
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO profiles (id, username, avatar_url, age, location, gender, skill_level)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO UPDATE SET
                username = COALESCE(EXCLUDED.username, profiles.username),
                avatar_url = COALESCE(EXCLUDED.avatar_url, profiles.avatar_url),
                age = COALESCE(EXCLUDED.age, profiles.age),
                location = COALESCE(EXCLUDED.location, profiles.location),
                gender = COALESCE(EXCLUDED.gender, profiles.gender),
                skill_level = COALESCE(EXCLUDED.skill_level, profiles.skill_level),
                updated_at = NOW()
            RETURNING *
            """,
            (
                str(user_id),
                body.username or "",
                body.avatar_url,
                body.age,
                body.location,
                body.gender,
                body.skill_level,
            ),
        )
        row = cur.fetchone()
        return dict(row)
