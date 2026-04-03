from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.auth_service import get_current_user
from app.services.insight_service import get_or_generate_insight

router = APIRouter()


@router.get("/daily")
def get_daily_insight(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Kembalikan insight harian user. Di-generate sekali per hari dan di-cache di DB."""
    text = get_or_generate_insight(current_user, db)
    return {"insight": text}
