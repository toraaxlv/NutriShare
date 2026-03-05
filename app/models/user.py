from sqlalchemy import Column, String, Float, Integer, DateTime, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id               = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email            = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password  = Column(String, nullable=False)
    name             = Column(String(100))
    age              = Column(Integer)
    weight_kg        = Column(Float)
    height_cm        = Column(Float)
    activity_level   = Column(String(20))  # sedentary|light|moderate|active|very_active
    goal             = Column(String(20))  # lose|maintain|gain
    created_at       = Column(DateTime(timezone=True), server_default=func.now())
    updated_at       = Column(DateTime(timezone=True), onupdate=func.now())