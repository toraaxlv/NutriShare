from sqlalchemy import Column, String, Float, Integer, Date, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid
from app.database import Base


class User(Base):
    __tablename__ = "users"

    id                      = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email                   = Column(String(255), unique=True, nullable=False, index=True)
    username                = Column(String(50), unique=True, nullable=True, index=True)
    hashed_password         = Column(String, nullable=False)
    name                    = Column(String(100))

    # Profil fisik
    gender                  = Column(String(10))   # male|female
    date_of_birth           = Column(Date)
    weight_kg               = Column(Float)
    height_cm               = Column(Float)

    # Aktivitas
    # no_activity|sedentary|light|moderate|very_active|custom
    activity_level          = Column(String(20))
    custom_exercise_calories = Column(Float)       # hanya dipakai jika activity_level = 'custom'

    # Goal
    goal                    = Column(String(20))   # lose|maintain|gain
    target_weight_kg        = Column(Float)
    # lose: 0.25|0.5|0.75|1.0 kg/week  |  gain: 0.25|0.5 kg/week  |  maintain: 0
    goal_rate_kg_per_week   = Column(Float, default=0.0)

    # Preferensi tracking
    water_target_ml         = Column(Integer, default=2000)

    created_at              = Column(DateTime(timezone=True), server_default=func.now())
    updated_at              = Column(DateTime(timezone=True), onupdate=func.now())
