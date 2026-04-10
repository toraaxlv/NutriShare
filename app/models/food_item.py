from sqlalchemy import Column, String, Float, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.database import Base

class FoodItem(Base):
    __tablename__ = "food_items"

    id                  = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name                = Column(String(200), nullable=False, index=True)
    calories_per_100g   = Column(Float, nullable=False)
    protein_per_100g    = Column(Float, nullable=False)
    carbs_per_100g      = Column(Float, nullable=False)
    fat_per_100g        = Column(Float, nullable=False)
    fiber_per_100g      = Column(Float)
    source              = Column(String(50), default="custom")
    # NULL = makanan publik (seed / cache API), diisi = custom milik user tertentu
    created_by          = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=True, index=True)