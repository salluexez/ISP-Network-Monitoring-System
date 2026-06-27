from datetime import datetime
from ipaddress import ip_address

from pydantic import BaseModel, Field, field_validator

from app.models.device import DeviceStatus, DeviceType, DeviceVendor


class DeviceBase(BaseModel):
    device_name: str = Field(min_length=1, max_length=255)
    hostname: str | None = Field(default=None, max_length=255)
    vendor: DeviceVendor
    device_type: DeviceType
    ip_address: str = Field(min_length=2, max_length=45)
    location_id: str | None = None
    parent_device_id: str | None = None
    status: DeviceStatus = DeviceStatus.UNKNOWN
    description: str | None = None

    @field_validator("ip_address")
    @classmethod
    def validate_ip_address(cls, value: str) -> str:
        try:
            return str(ip_address(value))
        except ValueError as exc:
            raise ValueError("ip_address must be a valid IPv4 or IPv6 address") from exc


class DeviceCreate(DeviceBase):
    pass


class DeviceUpdate(BaseModel):
    device_name: str | None = Field(default=None, min_length=1, max_length=255)
    hostname: str | None = Field(default=None, max_length=255)
    vendor: DeviceVendor | None = None
    device_type: DeviceType | None = None
    ip_address: str | None = Field(default=None, min_length=2, max_length=45)
    location_id: str | None = None
    parent_device_id: str | None = None
    status: DeviceStatus | None = None
    description: str | None = None

    @field_validator("ip_address")
    @classmethod
    def validate_ip_address(cls, value: str | None) -> str | None:
        if value is None:
            return value
        try:
            return str(ip_address(value))
        except ValueError as exc:
            raise ValueError("ip_address must be a valid IPv4 or IPv6 address") from exc


class DeviceResponse(DeviceBase):
    id: str
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class DeviceListResponse(BaseModel):
    items: list[DeviceResponse]
    total: int
    page: int
    page_size: int


class DeviceBulkImportRequest(BaseModel):
    devices: list[DeviceCreate] = Field(min_length=1, max_length=500)


class DeviceBulkImportResponse(BaseModel):
    created: list[DeviceResponse]
    failed: list[dict[str, str]]
