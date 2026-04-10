from sqlalchemy import Column, Float, String, Date, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.database import Base


class SleepLog(Base):
    __tablename__ = "sleep_logs"

    id             = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id        = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    log_date       = Column(Date, nullable=False)
    bed_time       = Column(String(5), nullable=False)   # "22:00"
    wake_time      = Column(String(5), nullable=False)   # "06:00"
    duration_hours = Column(Float, nullable=False)

    __table_args__ = (
        UniqueConstraint("user_id", "log_date", name="uq_sleep_log_user_date"),
    )
