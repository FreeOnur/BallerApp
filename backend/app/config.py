from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql://baller:baller@localhost:5432/baller"
    jwt_secret: str = "dev-only-change-in-production-min-32-chars"
    jwt_access_minutes: int = 15
    jwt_refresh_days: int = 30
    cors_origins: str = "http://localhost:*"
    environment: str = "development"

    b2_key_id: str = ""
    b2_app_key: str = ""
    b2_bucket: str = "courtfinder-images"
    b2_endpoint: str = "https://s3.us-west-002.backblazeb2.com"
    b2_region: str = "us-west-002"


settings = Settings()
