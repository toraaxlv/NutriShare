from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from app.routers import auth, profile, foods, logs, insights, weight_logs, water
from app.database import engine
from app import models

# Buat semua tabel otomatis
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Nutrishare API",
    description="Backend API Nutrisharee",
    version="1.0.0",
    docs_url=None,
    redoc_url=None,
)

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    first_error = exc.errors()[0]
    msg = first_error.get("msg", "Input tidak valid")
    # Pydantic v2 prefix "Value error, " — buang supaya pesan lebih bersih
    msg = msg.removeprefix("Value error, ")
    return JSONResponse(status_code=422, content={"detail": msg})

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
app.include_router(logs.router,     prefix="/api/v1/logs",     tags=["Logs"])
app.include_router(insights.router,     prefix="/api/v1/insights",     tags=["Insights"])
app.include_router(weight_logs.router,  prefix="/api/v1/weight-logs",  tags=["Weight Logs"])
app.include_router(water.router,        prefix="/api/v1/water",         tags=["Water"])

@app.get("/health", tags=["System"])
def health_check():
    return {"status": "ok", "service": "Nutrishare API v1.0"}