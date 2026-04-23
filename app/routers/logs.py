from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import date, timedelta
from pydantic import BaseModel, field_validator
from app.database import get_db
from app.models.food_log import FoodLog
from app.models.food_item import FoodItem
from app.schemas.food_log import FoodLogCreate, FoodLogResponse, DailySummary
from app.services.auth_service import get_current_user
from app.services.nutrition_service import calculate_targets
from app.services.insight_service import invalidate_today_insight
import uuid


class FoodLogUpdate(BaseModel):
    quantity_g: float

    @field_validator('quantity_g')
    @classmethod
    def quantity_must_be_positive(cls, v):
        if v <= 0 or v > 10000:
            raise ValueError('quantity_g harus antara 1-10000 gram')
        return v

router = APIRouter()


@router.post("/", response_model=FoodLogResponse, status_code=201)
def log_food(
    payload: FoodLogCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    if payload.food_item_id:
        food = db.query(FoodItem).filter(FoodItem.id == payload.food_item_id).first()
        if not food:
            raise HTTPException(status_code=404, detail="Food item tidak ditemukan")
    elif payload.food_name and payload.calories_per_100g is not None:
        import re
        def _norm(s): return re.sub(r'\s+', ' ', s.lower().strip())
        food = db.query(FoodItem).filter(
            FoodItem.created_by == None,  # noqa: E711
            FoodItem.source == payload.source,
        ).all()
        food = next((f for f in food if _norm(f.name) == _norm(payload.food_name)), None)
        if not food:
            food = FoodItem(
                name=payload.food_name,
                calories_per_100g=payload.calories_per_100g,
                protein_per_100g=payload.protein_per_100g or 0,
                carbs_per_100g=payload.carbs_per_100g or 0,
                fat_per_100g=payload.fat_per_100g or 0,
                fiber_per_100g=payload.fiber_per_100g,
                source=payload.source,
            )
            db.add(food)
            db.flush()
    else:
        raise HTTPException(status_code=422, detail="food_item_id atau data makanan wajib diisi")

    ratio = payload.quantity_g / 100
    log = FoodLog(
        user_id=current_user.id,
        food_item_id=food.id,
        log_date=payload.log_date,
        meal_type=payload.meal_type,
        quantity_g=payload.quantity_g,
        calories=round(food.calories_per_100g * ratio, 1),
        protein_g=round(food.protein_per_100g * ratio, 1),
        carbs_g=round(food.carbs_per_100g * ratio, 1),
        fat_g=round(food.fat_per_100g * ratio, 1),
    )
    db.add(log)
    db.commit()
    db.refresh(log)
    invalidate_today_insight(current_user.id, db)

    # Tambah nama makanan ke response
    log.food_name = food.name
    return log


@router.get("/summary")
def get_daily_summary(
    log_date: date,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    result = db.query(
        func.coalesce(func.sum(FoodLog.calories),  0).label("total_calories"),
        func.coalesce(func.sum(FoodLog.protein_g), 0).label("total_protein_g"),
        func.coalesce(func.sum(FoodLog.carbs_g),   0).label("total_carbs_g"),
        func.coalesce(func.sum(FoodLog.fat_g),     0).label("total_fat_g"),
    ).filter(
        FoodLog.user_id == current_user.id,
        FoodLog.log_date == log_date,
    ).one()

    targets = calculate_targets(current_user) or {}

    return {
        "date":            log_date,
        "total_calories":  result.total_calories,
        "total_protein_g": result.total_protein_g,
        "total_carbs_g":   result.total_carbs_g,
        "total_fat_g":     result.total_fat_g,
        **{f"target_{k}": v for k, v in targets.items()},
    }


@router.get("/")
def get_daily_logs(
    log_date: date,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    rows = (
        db.query(FoodLog, FoodItem.name.label("food_name"))
        .join(FoodItem, FoodLog.food_item_id == FoodItem.id)
        .filter(FoodLog.user_id == current_user.id, FoodLog.log_date == log_date)
        .all()
    )

    result = []
    for log, food_name in rows:
        log.food_name = food_name
        result.append(log)
    return result


@router.get("/history")
def get_daily_history(
    days: int = 7,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Ringkasan kalori per hari untuk N hari terakhir (termasuk hari ini)."""
    today = date.today()
    since = today - timedelta(days=days - 1)

    targets = calculate_targets(current_user) or {}
    cal_target = float(targets.get("calories", 0))

    rows2 = (
        db.query(
            FoodLog.log_date,
            func.coalesce(func.sum(FoodLog.calories),  0).label("calories"),
            func.coalesce(func.sum(FoodLog.protein_g), 0).label("protein_g"),
            func.coalesce(func.sum(FoodLog.carbs_g),   0).label("carbs_g"),
            func.coalesce(func.sum(FoodLog.fat_g),     0).label("fat_g"),
        )
        .filter(FoodLog.user_id == current_user.id, FoodLog.log_date >= since)
        .group_by(FoodLog.log_date)
        .order_by(FoodLog.log_date)
        .all()
    )
    logged2 = {r.log_date: r for r in rows2}

    result = []
    for i in range(days):
        d = since + timedelta(days=i)
        r = logged2.get(d)
        result.append({
            "date":       d.isoformat(),
            "calories":   float(r.calories)  if r else 0.0,
            "protein_g":  float(r.protein_g) if r else 0.0,
            "carbs_g":    float(r.carbs_g)   if r else 0.0,
            "fat_g":      float(r.fat_g)     if r else 0.0,
            "target":     cal_target,
        })
    return result


@router.get("/streak")
def get_streak(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """
    Streak = hari berturut-turut (dari hari ini ke belakang) dengan minimal 1 food log.
    Satu query untuk ambil semua tanggal, hitung di Python.
    """
    today = date.today()

    # Ambil semua log_date unik milik user dalam satu query
    logged_dates = {
        row.log_date
        for row in db.query(FoodLog.log_date)
        .filter(FoodLog.user_id == current_user.id)
        .distinct()
        .all()
    }

    streak = 0
    current_day = today
    while current_day in logged_dates:
        streak += 1
        current_day -= timedelta(days=1)

    return {"streak": streak}


@router.patch("/{log_id}", response_model=FoodLogResponse)
def update_log(
    log_id: uuid.UUID,
    payload: FoodLogUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    log = db.query(FoodLog).filter(
        FoodLog.id == log_id,
        FoodLog.user_id == current_user.id,
    ).first()
    if not log:
        raise HTTPException(status_code=404, detail="Log tidak ditemukan")

    food = db.query(FoodItem).filter(FoodItem.id == log.food_item_id).first()
    if not food:
        raise HTTPException(status_code=404, detail="Food item tidak ditemukan")

    ratio = payload.quantity_g / 100
    log.quantity_g = payload.quantity_g
    log.calories   = round(food.calories_per_100g * ratio, 1)
    log.protein_g  = round(food.protein_per_100g  * ratio, 1)
    log.carbs_g    = round(food.carbs_per_100g    * ratio, 1)
    log.fat_g      = round(food.fat_per_100g      * ratio, 1)
    db.commit()
    db.refresh(log)
    invalidate_today_insight(current_user.id, db)

    log.food_name = food.name
    return log


@router.delete("/{log_id}", status_code=204)
def delete_log(
    log_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    log = db.query(FoodLog).filter(
        FoodLog.id == log_id,
        FoodLog.user_id == current_user.id,
    ).first()
    if not log:
        raise HTTPException(status_code=404, detail="Log tidak ditemukan")
    db.delete(log)
    db.commit()
    invalidate_today_insight(current_user.id, db)
