from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.food_item import FoodItem
from app.services.auth_service import get_current_user
from app.ml_client.usda_client import search_usda
from app.ml_client.fatsecret_client import search_fatsecret
import asyncio

router = APIRouter()

@router.get("/search")
async def search_foods(
    q: str = Query(..., min_length=2, description="Nama makanan"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # 1. Cek DB lokal dulu
    local_results = db.query(FoodItem).filter(
        FoodItem.name.ilike(f"%{q}%")
    ).limit(10).all()

    # 2. Kalau lokal sudah cukup (10+), langsung return
    if len(local_results) >= 10:
        return {"source": "local", "results": local_results}

    # 3. Hit USDA + FatSecret secara parallel
    usda_results, fatsecret_results = await asyncio.gather(
        search_usda(q, max_results=10),
        search_fatsecret(q, max_results=10),
        return_exceptions=True
    )

    # Handle kalau salah satu API error
    if isinstance(usda_results, Exception):
        usda_results = []
    if isinstance(fatsecret_results, Exception):
        fatsecret_results = []

    # 4. Gabungkan & hapus duplikat berdasarkan nama
    combined = usda_results + fatsecret_results
    seen_names = {item.name.lower() for item in local_results}
    new_items = []

    for item_data in combined:
        name_lower = item_data["name"].lower()
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

@router.get("/")
def list_foods(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    return db.query(FoodItem).limit(50).all()
