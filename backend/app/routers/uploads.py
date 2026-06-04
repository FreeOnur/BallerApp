"""Presigned uploads to Backblaze B2 (S3-compatible). Keys stay server-side only."""

from typing import Annotated
from uuid import UUID

import boto3
from botocore.config import Config
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from app.config import settings
from app.dependencies import get_current_user_id

router = APIRouter(prefix="/uploads", tags=["uploads"])


class PresignRequest(BaseModel):
    filename: str = Field(min_length=1, max_length=255)
    court_id: UUID | None = None
    kind: str = Field(default="court_image", pattern="^(court_image|avatar)$")


class PresignResponse(BaseModel):
    upload_url: str
    storage_path: str
    public_url: str


def _b2_configured() -> bool:
    return bool(
        getattr(settings, "b2_key_id", None)
        and getattr(settings, "b2_app_key", None)
        and getattr(settings, "b2_bucket", None)
    )


@router.post("/presign", response_model=PresignResponse)
def create_presigned_upload(
    body: PresignRequest,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
) -> PresignResponse:
    if not _b2_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="B2 storage not configured on server (set B2_* in .env)",
        )

    safe_name = body.filename.replace("\\", "/").split("/")[-1]
    if body.kind == "avatar":
        storage_path = f"avatars/{user_id}/{safe_name}"
    elif body.court_id:
        storage_path = f"courts/{body.court_id}/{safe_name}"
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="court_id required for court_image uploads",
        )

    client = boto3.client(
        "s3",
        endpoint_url=settings.b2_endpoint,
        region_name=settings.b2_region,
        aws_access_key_id=settings.b2_key_id,
        aws_secret_access_key=settings.b2_app_key,
        config=Config(signature_version="s3v4"),
    )

    upload_url = client.generate_presigned_url(
        "put_object",
        Params={"Bucket": settings.b2_bucket, "Key": storage_path},
        ExpiresIn=300,
    )

    public_url = f"{settings.b2_endpoint.rstrip('/')}/{settings.b2_bucket}/{storage_path}"

    return PresignResponse(
        upload_url=upload_url,
        storage_path=storage_path,
        public_url=public_url,
    )
