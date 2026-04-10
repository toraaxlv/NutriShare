from sqlalchemy import Column, String, Float, Date, DateTime, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid
from app.database import Base

class FoodLog(Base):
    __tablename__ = "food_logs"

    id           = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id      = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    food_item_id = Column(UUID(as_uuid=True), ForeignKey("food_items.id"), nullable=False)
    log_date     = Column(Date, nullable=False)
    meal_type    = Column(String(20))   # breakfast|lunch|dinner|snack
    quantity_g   = Column(Float, nullable=False)
    calories     = Column(Float, nullable=False)
    protein_g    = Column(Float, nullable=False)
    carbs_g      = Column(Float, nullable=False)
    fat_g        = Column(Float, nullable=False)
    created_at   = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        Index('ix_food_log_user_date', 'user_id', 'log_date'),
    )