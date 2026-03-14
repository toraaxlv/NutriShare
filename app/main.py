from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, profile, foods, logs
from app.database import engine
from app import models

# Buat semua tabel otomatis
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Nutrishare API",
    description="Backend API Nutrisharee",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router,    prefix="/api/v1/auth",    tags=["Auth"])
app.include_router(profile.router, prefix="/api/v1/profile", tags=["Profile"])
app.include_router(foods.router,   prefix="/api/v1/foods",   tags=["Foods"])
app.include_router(logs.router,    prefix="/api/v1/logs",    tags=["Logs"])

@app.get("/health", tags=["System"])
def health_check():
    return {"status": "ok", "service": "Nutrishare API v1.0"}