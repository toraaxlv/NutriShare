from sqlalchemy import Column, String, Float, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.database import Base

class RecipeIngredient(Base):
    __tablename__ = "recipe_ingredients"

    id              = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    recipe_id       = Column(UUID(as_uuid=True), ForeignKey("food_items.id", ondelete="CASCADE"), nullable=False, index=True)
    name            = Column(String(200), nullable=False)
    calories_per_100g = Column(Float, nullable=False)
    protein_per_100g  = Column(Float, nullable=False)
    carbs_per_100g    = Column(Float, nullable=False)
    fat_per_100g      = Column(Float, nullable=False)
    fiber_per_100g    = Column(Float, default=0)
    source          = Column(String(50), default="usda")
    quantity_g      = Column(Float, nullable=False)
