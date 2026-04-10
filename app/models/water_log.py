from sqlalchemy import Column, Integer, Date, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.database import Base


class WaterLog(Base):
    __tablename__ = "water_logs"

    id        = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id   = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    log_date  = Column(Date, nullable=False)
    amount_ml = Column(Integer, nullable=False, default=0)

    __table_args__ = (
        UniqueConstraint("user_id", "log_date", name="uq_water_log_user_date"),
    )
