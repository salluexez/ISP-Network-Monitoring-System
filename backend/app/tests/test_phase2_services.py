import pytest
from fastapi import HTTPException
from pydantic import ValidationError

from app.models.device import Device
from app.models.location import Location
from app.schemas.device import DeviceBulkImportRequest, DeviceCreate
from app.schemas.location import LocationCreate
from app.services.device_service import DeviceService
from app.services.location_service import LocationService


class FakeLocationRepository:
    def __init__(self) -> None:
        self.items: dict[str, Location] = {}

    def create(self, location: Location) -> Location:
        self.items[location.id] = location
        return location

    def get(self, location_id: str) -> Location | None:
        return self.items.get(location_id)

    def list(self, **_: object) -> tuple[list[Location], int]:
        return list(self.items.values()), len(self.items)

    def update(self, location: Location, values: dict[str, object]) -> Location:
        for key, value in values.items():
            setattr(location, key, value)
        return location

    def delete(self, location: Location) -> None:
        self.items.pop(location.id, None)


class FakeDeviceRepository:
    def __init__(self) -> None:
        self.items: dict[str, Device] = {}

    def create(self, device: Device) -> Device:
        self.items[device.id] = device
        return device

    def get(self, device_id: str) -> Device | None:
        return self.items.get(device_id)

    def get_by_ip(self, ip_address: str) -> Device | None:
        return next((device for device in self.items.values() if device.ip_address == ip_address), None)

    def list(self, **_: object) -> tuple[list[Device], int]:
        return list(self.items.values()), len(self.items)

    def update(self, device: Device, values: dict[str, object]) -> Device:
        for key, value in values.items():
            setattr(device, key, value)
        return device

    def delete(self, device: Device) -> None:
        self.items.pop(device.id, None)


def test_location_requires_existing_parent() -> None:
    service = LocationService(FakeLocationRepository())

    with pytest.raises(HTTPException) as exc:
        service.create(
            LocationCreate(
                location_name="Tower A",
                location_type="TOWER",
                parent_location_id="missing",
            )
        )

    assert exc.value.status_code == 400


def test_device_rejects_duplicate_ip() -> None:
    location_repo = FakeLocationRepository()
    device_repo = FakeDeviceRepository()
    service = DeviceService(device_repo, location_repo)

    payload = DeviceCreate(
        device_name="Core Router",
        vendor="MikroTik",
        device_type="ROUTER",
        ip_address="10.0.0.1",
    )
    service.create(payload)

    with pytest.raises(HTTPException) as exc:
        service.create(payload)

    assert exc.value.status_code == 409


def test_device_ip_validation_accepts_ipv6_and_rejects_invalid_ip() -> None:
    device = DeviceCreate(
        device_name="IPv6 Router",
        vendor="Cisco",
        device_type="ROUTER",
        ip_address="2001:db8::1",
    )
    assert device.ip_address == "2001:db8::1"

    with pytest.raises(ValidationError):
        DeviceCreate(device_name="Bad Router", vendor="Cisco", device_type="ROUTER", ip_address="999.1.1.1")


def test_bulk_import_keeps_successes_and_reports_failures() -> None:
    service = DeviceService(FakeDeviceRepository(), FakeLocationRepository())
    payload = DeviceBulkImportRequest(
        devices=[
            DeviceCreate(device_name="Router 1", vendor="MikroTik", device_type="ROUTER", ip_address="10.0.0.1"),
            DeviceCreate(device_name="Router 2", vendor="MikroTik", device_type="ROUTER", ip_address="10.0.0.1"),
        ]
    )

    created, failed = service.bulk_import(payload)

    assert len(created) == 1
    assert failed == [{"index": "1", "device_name": "Router 2", "error": "IP address already exists"}]
