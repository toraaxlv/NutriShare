from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 43200  # 30 hari
    ML_SERVICE_URL: str = "http://localhost:8001"
    USDA_API_KEY: str = ""

    class Config:
        env_file = ".env"

settings = Settings()