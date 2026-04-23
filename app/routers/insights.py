from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.auth_service import get_current_user
from app.services.insight_service import get_or_generate_insight
from app.models.insight import UserInsight
from datetime import date

router = APIRouter()


@router.get("/daily")
def get_daily_insight(
    force: bool = Query(False),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Kembalikan insight harian user. Di-generate sekali per hari dan di-cache di DB."""
    if force:
        db.query(UserInsight).filter(
            UserInsight.user_id == current_user.id,
            UserInsight.generated_date == date.today(),
        ).delete()
        db.commit()
    text = get_or_generate_insight(current_user, db)
    return {"insight": text}
