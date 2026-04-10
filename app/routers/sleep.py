from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy.dialects.postgresql import insert
from datetime import date as date_type
from pydantic import BaseModel, field_validator
from app.database import get_db
from app.models.sleep_log import SleepLog
from app.models.user import User
from app.services.auth_service import get_current_user

router = APIRouter()


class SleepLogUpsert(BaseModel):
    log_date: date_type
    bed_time: str        # "22:00"
    wake_time: str       # "06:00"
    duration_hours: float

    @field_validator("bed_time", "wake_time")
    @classmethod
    def valid_time_format(cls, v):
        parts = v.split(":")
        if len(parts) != 2:
            raise ValueError("Format waktu harus HH:MM")
        h, m = int(parts[0]), int(parts[1])
        if not (0 <= h <= 23 and 0 <= m <= 59):
            raise ValueError("Jam atau menit tidak valid")
        return v

    @field_validator("duration_hours")
    @classmethod
    def must_be_positive(cls, v):
        if v <= 0:
            raise ValueError("duration_hours harus lebih dari 0")
        return v


@router.get("/")
def get_sleep(
    log_date: date_type,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    row = (
        db.query(SleepLog)
        .filter(SleepLog.user_id == current_user.id, SleepLog.log_date == log_date)
        .first()
    )
    if not row:
        return None
    return {
        "log_date":       str(row.log_date),
        "bed_time":       row.bed_time,
        "wake_time":      row.wake_time,
        "duration_hours": row.duration_hours,
    }


@router.put("/")
def upsert_sleep(
    payload: SleepLogUpsert,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    stmt = insert(SleepLog).values(
        user_id=current_user.id,
        log_date=payload.log_date,
        bed_time=payload.bed_time,
        wake_time=payload.wake_time,
        duration_hours=payload.duration_hours,
    ).on_conflict_do_update(
        constraint="uq_sleep_log_user_date",
        set_={
            "bed_time":       payload.bed_time,
            "wake_time":      payload.wake_time,
            "duration_hours": payload.duration_hours,
        },
    )
    db.execute(stmt)
    db.commit()

    return {
        "log_date":       payload.log_date,
        "bed_time":       payload.bed_time,
        "wake_time":      payload.wake_time,
        "duration_hours": payload.duration_hours,
    }
