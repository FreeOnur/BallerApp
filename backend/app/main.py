from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routers import auth, courts, profiles, uploads

app = FastAPI(
    title="BallerApp API",
    version="0.1.0",
    description="Self-hosted backend for BallerApp (replaces Supabase for data + auth on cutover).",
)

origins = [o.strip() for o in settings.cors_origins.split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins if origins != ["*"] else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(courts.router)
app.include_router(profiles.router)
app.include_router(uploads.router)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "environment": settings.environment}
