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
    # 1. Custom foods milik user ini duluan (prioritas tertinggi)
    custom_results = db.query(FoodItem).filter(
        FoodItem.name.ilike(f"%{q}%"),
        FoodItem.source == "custom",
        FoodItem.created_by == current_user.id,
    ).all()

    # 2. Sisa slot dari DB publik (seed + cache API, bukan custom siapapun)
    remaining = max(0, 10 - len(custom_results))
    other_results = db.query(FoodItem).filter(
        FoodItem.name.ilike(f"%{q}%"),
        FoodItem.created_by == None,  # noqa: E711 — SQLAlchemy IS NULL
    ).limit(remaining).all()

    local_results = custom_results + other_results

    # 3. Kalau lokal sudah cukup (10+), langsung return
    if len(local_results) >= 10:
        return {"source": "local", "results": local_results}

    # 3. Hit USDA API
    try:
        usda_results = await search_usda(q, max_results=10)
    except Exception:
        usda_results = []

    # 4. Hapus duplikat berdasarkan nama
    combined = usda_results
    def _normalize(name: str) -> str:
        import re
        return re.sub(r'\s+', ' ', name.lower().strip())

    seen_names = {_normalize(item.name) for item in local_results}
    new_items = []

    for item_data in combined:
        name_lower = _normalize(item_data["name"])
        if name_lower not in seen_names and item_data["calories_per_100g"] > 0:
            seen_names.add(name_lower)

            # 5. Cache ke DB lokal
            food = FoodItem(
                name=item_data["name"],
                calories_per_100g=item_data["calories_per_100g"],
                protein_per_100g=item_data["protein_per_100g"],
                carbs_per_100g=item_data["carbs_per_100g"],
                fat_per_100g=item_data["fat_per_100g"],
                fiber_per_100g=item_data.get("fiber_per_100g", 0),
                source=item_data["source"]
            )
            db.add(food)
            new_items.append(food)

    if new_items:
        db.commit()
        for item in new_items:
            db.refresh(item)

    all_results = list(local_results) + new_items
    return {
        "source": "mixed",
        "total": len(all_results),
        "results": all_results
    }

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
