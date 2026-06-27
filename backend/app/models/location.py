from datetime import datetime, timezone
from enum import StrEnum
from uuid import uuid4

from sqlalchemy import DateTime, Enum, Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class LocationType(StrEnum):
    CORE = "CORE"
    POP = "POP"
    TOWER = "TOWER"
    VILLAGE = "VILLAGE"
    OLT_ROOM = "OLT_ROOM"


class Location(Base):
    __tablename__ = "locations"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    location_name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    location_type: Mapped[LocationType] = mapped_column(Enum(LocationType), nullable=False, index=True)
    latitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    longitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    parent_location_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("locations.id", ondelete="SET NULL"), nullable=True, index=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    parent: Mapped["Location | None"] = relationship(remote_side=[id], back_populates="children")
    children: Mapped[list["Location"]] = relationship(back_populates="parent", passive_deletes=True)
