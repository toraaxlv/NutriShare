from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy.dialects.postgresql import insert
from datetime import date as date_type
from pydantic import BaseModel, field_validator
from app.database import get_db
from app.models.water_log import WaterLog
from app.models.user import User
from app.services.auth_service import get_current_user

router = APIRouter()


class WaterLogUpsert(BaseModel):
    log_date: date_type
    amount_ml: int

    @field_validator("amount_ml")
    @classmethod
    def must_be_non_negative(cls, v):
        if v < 0:
            raise ValueError("amount_ml tidak boleh negatif")
        return v


@router.get("/")
def get_water(
    log_date: date_type,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    row = (
        db.query(WaterLog)
        .filter(WaterLog.user_id == current_user.id, WaterLog.log_date == log_date)
        .first()
    )
    return {
        "log_date":  log_date,
        "amount_ml": row.amount_ml if row else 0,
        "target_ml": _water_target(current_user),
    }


@router.put("/")
def upsert_water(
    payload: WaterLogUpsert,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    stmt = insert(WaterLog).values(
        user_id=current_user.id,
        log_date=payload.log_date,
        amount_ml=payload.amount_ml,
    ).on_conflict_do_update(
        constraint="uq_water_log_user_date",
        set_={"amount_ml": payload.amount_ml},
    )
    db.execute(stmt)
    db.commit()

    return {
        "log_date":  payload.log_date,
        "amount_ml": payload.amount_ml,
        "target_ml": _water_target(current_user),
    }


def _water_target(user: User) -> int:
    if user.water_target_ml and user.water_target_ml != 2000:
        return user.water_target_ml
    if user.gender == "male":
        return 3700
    if user.gender == "female":
        return 2700
    return 2500
