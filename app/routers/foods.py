from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.food_item import FoodItem
from app.services.auth_service import get_current_user

router = APIRouter()

@router.get("/search")
def search_foods(
    q: str = Query(..., min_length=2, description="Nama makanan"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    results = db.query(FoodItem).filter(
        FoodItem.name.ilike(f"%{q}%")
    ).limit(20).all()
    return results

@router.get("/")
def list_foods(db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    return db.query(FoodItem).limit(50).all()