from functools import lru_cache
from typing import List

from pydantic import Field, PostgresDsn, computed_field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "ISP Network Monitoring System"
    api_v1_prefix: str = "/api/v1"
    environment: str = Field(default="development")
    debug: bool = Field(default=True)

    postgres_host: str = Field(default="localhost")
    postgres_port: int = Field(default=5432)
    postgres_db: str = Field(default="isp_noc")
    postgres_user: str = Field(default="isp_noc")
    postgres_password: str = Field(default="change-me")

    jwt_secret_key: str = Field(default="change-this-secret-in-production")
    jwt_algorithm: str = Field(default="HS256")
    access_token_expire_minutes: int = Field(default=60 * 8)

    initial_admin_email: str = Field(default="admin@example.com")
    initial_admin_password: str = Field(default="ChangeMe123!")

    cors_origins: str = Field(default="http://localhost:3000,http://localhost:8080,http://localhost:5173")

    @computed_field  # type: ignore[prop-decorator]
    @property
    def database_url(self) -> str:
        dsn = PostgresDsn.build(
            scheme="postgresql+psycopg",
            username=self.postgres_user,
            password=self.postgres_password,
            host=self.postgres_host,
            port=self.postgres_port,
            path=self.postgres_db,
        )
        return str(dsn)

    @property
    def allowed_origins(self) -> List[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
