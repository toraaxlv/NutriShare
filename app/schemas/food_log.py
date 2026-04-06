from pydantic import BaseModel
from typing import Optional
from datetime import date
import uuid

class FoodLogCreate(BaseModel):
    food_item_id: uuid.UUID
    log_date: date
    meal_type: str        # breakfast|lunch|dinner|snack
    quantity_g: float

class FoodLogResponse(BaseModel):
    id: uuid.UUID
    food_item_id: uuid.UUID
    food_name: Optional[str] = None   # di-populate via join di router
    log_date: date
    meal_type: str
    quantity_g: float
    calories: float
    protein_g: float
    carbs_g: float
    fat_g: float

    class Config:
        from_attributes = True

class DailySummary(BaseModel):
    date: date
    total_calories: float
    total_protein_g: float
    total_carbs_g: float
    total_fat_g: float
    target_calories: Optional[int]
    target_protein_g: Optional[float]
    target_carbs_g: Optional[float]
    target_fat_g: Optional[float]