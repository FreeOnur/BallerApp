from typing import Annotated, Any
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from app.db import get_conn
from app.dependencies import get_current_user_id

router = APIRouter(prefix="/courts", tags=["courts"])


class CreateCourtRequest(BaseModel):
    name: str
    lat: float
    lng: float
    indoor: bool = False
    lights: bool = False
    has_markings: bool = False
    surface: str | None = None
    hoops: int | None = None
    address: str | None = None


@router.get("")
def list_approved_courts() -> list[dict[str, Any]]:
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM courts WHERE status = %s ORDER BY created_at DESC", ("approved",))
        return [dict(row) for row in cur.fetchall()]


@router.post("", status_code=status.HTTP_201_CREATED)
def create_court(
    body: CreateCourtRequest,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
) -> dict[str, str]:
    court_id = uuid4()
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO courts (
                id, source, name, lat, lng, indoor, lights, has_markings,
                surface, hoops, address, status
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (
                str(court_id),
                "community",
                body.name,
                body.lat,
                body.lng,
                body.indoor,
                body.lights,
                body.has_markings,
                body.surface,
                body.hoops,
                body.address,
                "pending",
            ),
        )
    return {"id": str(court_id)}


class CourtImageCreate(BaseModel):
    file_path: str = Field(min_length=1)


@router.post("/{court_id}/images", status_code=status.HTTP_201_CREATED)
def add_court_image(
    court_id: UUID,
    body: CourtImageCreate,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
) -> dict[str, str]:
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT id FROM courts WHERE id = %s", (str(court_id),))
        if cur.fetchone() is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Court not found")
        cur.execute(
            "INSERT INTO court_images (court_id, file_path) VALUES (%s, %s) RETURNING id",
            (str(court_id), body.file_path),
        )
        row = cur.fetchone()
        return {"id": str(row["id"]), "file_path": body.file_path}


@router.get("/{court_id}")
def get_court(court_id: UUID) -> dict[str, Any]:
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM courts WHERE id = %s", (str(court_id),))
        row = cur.fetchone()
        if row is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Court not found")
        return dict(row)
