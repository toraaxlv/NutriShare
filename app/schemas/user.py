from pydantic import BaseModel, EmailStr
from typing import Optional
import uuid

class UserRegister(BaseModel):
    email: EmailStr
    password: str
    name: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    age: Optional[int] = None
    weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    activity_level: Optional[str] = None  # sedentary|light|moderate|active|very_active
    goal: Optional[str] = None            # lose|maintain|gain

class UserResponse(BaseModel):
    id: uuid.UUID
    email: str
    name: Optional[str]
    age: Optional[int]
    weight_kg: Optional[float]
    height_cm: Optional[float]
    activity_level: Optional[str]
    goal: Optional[str]

    class Config:
        from_attributes = True

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"