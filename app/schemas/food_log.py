from pydantic import BaseModel, field_validator
from typing import Optional
from datetime import date
import uuid

class FoodLogCreate(BaseModel):
    # Untuk makanan lokal/custom yang sudah ada di DB
    food_item_id: Optional[uuid.UUID] = None
    # Untuk makanan USDA yang belum di-DB (lazy insert saat log)
    food_name: Optional[str] = None
    calories_per_100g: Optional[float] = None
    protein_per_100g: Optional[float] = None
    carbs_per_100g: Optional[float] = None
    fat_per_100g: Optional[float] = None
    fiber_per_100g: float = 0
    source: str = "usda"

    log_date: date
    meal_type: str        # breakfast|lunch|dinner|snack
    quantity_g: float

    @field_validator('quantity_g')
    @classmethod
    def quantity_must_be_positive(cls, v):
        if v <= 0 or v > 10000:
            raise ValueError('quantity_g harus antara 1-10000 gram')
        return v

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