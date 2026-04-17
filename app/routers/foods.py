from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from app.database import get_db
from app.models.food_item import FoodItem
from app.services.auth_service import get_current_user
from app.ml_client.usda_client import search_usda

router = APIRouter()


class FoodItemCreate(BaseModel):
    name: str
    calories_per_100g: float
    protein_per_100g: float
    carbs_per_100g: float
    fat_per_100g: float
    fiber_per_100g: Optional[float] = 0.0

@router.get("/custom")
def list_custom_foods(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Kembalikan custom foods milik user yang sedang login saja."""
    return (
        db.query(FoodItem)
        .filter(FoodItem.source == "custom", FoodItem.created_by == current_user.id)
        .order_by(FoodItem.name)
        .all()
    )


@router.get("/search")
async def search_foods(
    q: str = Query(..., min_length=2, description="Nama makanan"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    import re
    def _normalize(name: str) -> str:
        return re.sub(r'\s+', ' ', name.lower().strip())

    # 1. Custom foods milik user ini duluan (prioritas tertinggi)
    custom_results = db.query(FoodItem).filter(
        FoodItem.name.ilike(f"%{q}%"),
        FoodItem.source == "custom",
        FoodItem.created_by == current_user.id,
    ).all()

    # 2. Makanan publik dari DB (seed, bukan custom siapapun)
    other_results = db.query(FoodItem).filter(
        FoodItem.name.ilike(f"%{q}%"),
        FoodItem.created_by == None,  # noqa: E711 — SQLAlchemy IS NULL
    ).limit(20).all()

    local_results = custom_results + other_results

    # 3. Ambil sisa kuota dari USDA tanpa menyimpan ke DB
    try:
        usda_raw = await search_usda(q, max_results=20)
    except Exception:
        usda_raw = []

    seen_names = {_normalize(item.name) for item in local_results}
    usda_results = []
    for item_data in usda_raw:
        name_lower = _normalize(item_data["name"])
        if name_lower not in seen_names and item_data["calories_per_100g"] > 0:
            seen_names.add(name_lower)
            usda_results.append(item_data)

    all_results = [
        {"id": str(item.id), "name": item.name, "source": item.source,
         "calories_per_100g": item.calories_per_100g, "protein_per_100g": item.protein_per_100g,
         "carbs_per_100g": item.carbs_per_100g, "fat_per_100g": item.fat_per_100g,
         "fiber_per_100g": item.fiber_per_100g or 0}
        for item in local_results
    ] + usda_results  # USDA tidak punya id

    return {"source": "mixed", "total": len(all_results), "results": all_results}

@router.post("/", status_code=201)
def create_food(
    payload: FoodItemCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    food = FoodItem(
        name=payload.name,
        calories_per_100g=payload.calories_per_100g,
        protein_per_100g=payload.protein_per_100g,
        carbs_per_100g=payload.carbs_per_100g,
        fat_per_100g=payload.fat_per_100g,
        fiber_per_100g=payload.fiber_per_100g,
        source="custom",
        created_by=current_user.id,
    )
    db.add(food)
    db.commit()
    db.refresh(food)
    return food


@router.get("/")
def list_foods(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Hanya kembalikan makanan publik (bukan custom milik siapapun)
    return db.query(FoodItem).filter(FoodItem.created_by == None).limit(50).all()  # noqa: E711
