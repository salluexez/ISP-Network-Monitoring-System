from datetime import datetime, timezone
from enum import StrEnum
from uuid import uuid4

from sqlalchemy import DateTime, Enum, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class DeviceVendor(StrEnum):
    MIKROTIK = "MikroTik"
    UBIQUITI = "Ubiquiti"
    HUAWEI = "Huawei"
    VSOL = "VSOL"
    BDCOM = "BDCOM"
    CISCO = "Cisco"
    GENERIC = "Generic"


class DeviceType(StrEnum):
    ROUTER = "ROUTER"
    SWITCH = "SWITCH"
    OLT = "OLT"
    ONU = "ONU"
    TOWER = "TOWER"
    ACCESS_POINT = "ACCESS_POINT"
    SERVER = "SERVER"


class DeviceStatus(StrEnum):
    ONLINE = "ONLINE"
    OFFLINE = "OFFLINE"
    UNKNOWN = "UNKNOWN"


class Device(Base):
    __tablename__ = "devices"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    device_name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    hostname: Mapped[str | None] = mapped_column(String(255), nullable=True, index=True)
    vendor: Mapped[DeviceVendor] = mapped_column(
        Enum(DeviceVendor, values_callable=lambda values: [item.value for item in values]),
        nullable=False,
        index=True,
    )
    device_type: Mapped[DeviceType] = mapped_column(
        Enum(DeviceType, values_callable=lambda values: [item.value for item in values]),
        nullable=False,
        index=True,
    )
    ip_address: Mapped[str] = mapped_column(String(45), nullable=False, unique=True, index=True)
    location_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("locations.id", ondelete="SET NULL"), nullable=True, index=True
    )
    parent_device_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("devices.id", ondelete="SET NULL"), nullable=True, index=True
    )
    status: Mapped[DeviceStatus] = mapped_column(
        Enum(DeviceStatus, values_callable=lambda values: [item.value for item in values]),
        nullable=False,
        default=DeviceStatus.UNKNOWN,
    )
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    location: Mapped["Location | None"] = relationship("Location")
    parent: Mapped["Device | None"] = relationship(remote_side=[id], back_populates="children")
    children: Mapped[list["Device"]] = relationship(back_populates="parent", passive_deletes=True)
