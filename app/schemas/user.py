from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional
from datetime import date
import uuid


class UserRegister(BaseModel):
    username: str
    email: EmailStr
    password: str
    name: Optional[str] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    gender: Optional[str] = None                      # male|female
    date_of_birth: Optional[date] = None
    weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    activity_level: Optional[str] = None              # no_activity|sedentary|light|moderate|very_active|custom
    custom_exercise_calories: Optional[float] = None  # hanya untuk activity_level='custom'
    goal: Optional[str] = None                        # lose|maintain|gain
    target_weight_kg: Optional[float] = None
    goal_rate_kg_per_week: Optional[float] = None     # lose: 0.25-1.0 | gain: 0.25-0.5 | maintain: 0
    water_target_ml: Optional[int] = None             # target minum air harian (ml)

    @field_validator('weight_kg')
    @classmethod
    def weight_must_be_valid(cls, v):
        if v is not None and (v <= 0 or v > 500):
            raise ValueError('weight_kg harus antara 1-500 kg')
        return v

    @field_validator('height_cm')
    @classmethod
    def height_must_be_valid(cls, v):
        if v is not None and (v <= 0 or v > 300):
            raise ValueError('height_cm harus antara 1-300 cm')
        return v

    @field_validator('target_weight_kg')
    @classmethod
    def target_weight_must_be_valid(cls, v):
        if v is not None and (v <= 0 or v > 500):
            raise ValueError('target_weight_kg harus antara 1-500 kg')
        return v


class UserResponse(BaseModel):
    id: uuid.UUID
    email: str
    username: Optional[str]
    name: Optional[str]
    gender: Optional[str]
    date_of_birth: Optional[date]
    weight_kg: Optional[float]
    height_cm: Optional[float]
    activity_level: Optional[str]
    custom_exercise_calories: Optional[float]
    goal: Optional[str]
    target_weight_kg: Optional[float]
    goal_rate_kg_per_week: Optional[float]
    water_target_ml: Optional[int] = 2000

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
