from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy.dialects.postgresql import insert
from datetime import date as date_type
from pydantic import BaseModel
from app.database import get_db
from app.models.weight_log import WeightLog
from app.models.user import User
from app.services.auth_service import get_current_user

router = APIRouter()


class WeightLogCreate(BaseModel):
    log_date: date_type
    weight_kg: float


@router.post("/", status_code=201)
def log_weight(
    payload: WeightLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Upsert: update weight_kg jika tanggal sudah ada
    stmt = insert(WeightLog).values(
        user_id=current_user.id,
        log_date=payload.log_date,
        weight_kg=payload.weight_kg,
    ).on_conflict_do_update(
        constraint="uq_weight_log_user_date",
        set_={"weight_kg": payload.weight_kg},
    )
    db.execute(stmt)

    # Update current weight di profil hanya jika log untuk hari ini
    from datetime import date as _date
    if payload.log_date == _date.today():
        current_user.weight_kg = payload.weight_kg
    db.commit()

    return {"log_date": payload.log_date, "weight_kg": payload.weight_kg}


@router.get("/")
def get_weight_history(
    limit: int = 30,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    rows = (
        db.query(WeightLog)
        .filter(WeightLog.user_id == current_user.id)
        .order_by(WeightLog.log_date.asc())
        .limit(limit)
        .all()
    )
    return [{"log_date": str(r.log_date), "weight_kg": r.weight_kg} for r in rows]
