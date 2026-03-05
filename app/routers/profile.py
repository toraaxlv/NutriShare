from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.user import UserProfileUpdate, UserResponse
from app.services.auth_service import get_current_user
from app.services.nutrition_service import calculate_targets
from app.models.user import User

router = APIRouter()

@router.get("/", response_model=UserResponse)
def get_profile(current_user: User = Depends(get_current_user)):
    return current_user

@router.put("/", response_model=UserResponse)
def update_profile(
    payload: UserProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(current_user, field, value)
    db.commit()
    db.refresh(current_user)
    return current_user

@router.get("/targets")
def get_targets(current_user: User = Depends(get_current_user)):
    targets = calculate_targets(current_user)
    if not targets:
        return {"message": "Lengkapi profile kamu dulu (berat, tinggi, usia, aktivitas, goal)"}
    return targets