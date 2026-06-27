from fastapi import HTTPException, status

from app.models.device import Device, DeviceType, DeviceVendor
from app.repositories.device_repository import DeviceRepository
from app.repositories.location_repository import LocationRepository
from app.schemas.device import DeviceBulkImportRequest, DeviceCreate, DeviceUpdate


class DeviceService:
    def __init__(self, device_repository: DeviceRepository, location_repository: LocationRepository) -> None:
        self.device_repository = device_repository
        self.location_repository = location_repository

    def create(self, payload: DeviceCreate) -> Device:
        self._validate_location(payload.location_id)
        self._validate_parent(payload.parent_device_id)
        self._validate_unique_ip(payload.ip_address)
        return self.device_repository.create(Device(**payload.model_dump()))

    def get(self, device_id: str) -> Device:
        device = self.device_repository.get(device_id)
        if device is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
        return device

    def list(
        self,
        *,
        search: str | None,
        vendor: DeviceVendor | None,
        device_type: DeviceType | None,
        location_id: str | None,
        page: int,
        page_size: int,
        sort_by: str,
        sort_dir: str,
    ) -> tuple[list[Device], int]:
        return self.device_repository.list(
            search=search,
            vendor=vendor,
            device_type=device_type,
            location_id=location_id,
            page=page,
            page_size=page_size,
            sort_by=sort_by,
            sort_dir=sort_dir,
        )

    def update(self, device_id: str, payload: DeviceUpdate) -> Device:
        device = self.get(device_id)
        values = payload.model_dump(exclude_unset=True)
        if "location_id" in values:
            self._validate_location(values["location_id"])
        if "parent_device_id" in values:
            parent_device_id = values["parent_device_id"]
            if parent_device_id == device_id:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Device cannot parent itself")
            self._validate_parent(parent_device_id)
        if "ip_address" in values and values["ip_address"] != device.ip_address:
            self._validate_unique_ip(str(values["ip_address"]))
        return self.device_repository.update(device, values)

    def delete(self, device_id: str) -> None:
        self.device_repository.delete(self.get(device_id))

    def bulk_import(self, payload: DeviceBulkImportRequest) -> tuple[list[Device], list[dict[str, str]]]:
        created: list[Device] = []
        failed: list[dict[str, str]] = []
        for index, device_payload in enumerate(payload.devices):
            try:
                created.append(self.create(device_payload))
            except HTTPException as exc:
                failed.append({"index": str(index), "device_name": device_payload.device_name, "error": str(exc.detail)})
        return created, failed

    def _validate_unique_ip(self, ip_address: str) -> None:
        if self.device_repository.get_by_ip(ip_address) is not None:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="IP address already exists")

    def _validate_location(self, location_id: str | None) -> None:
        if location_id is not None and self.location_repository.get(location_id) is None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Location does not exist")

    def _validate_parent(self, parent_device_id: str | None) -> None:
        if parent_device_id is not None and self.device_repository.get(parent_device_id) is None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Parent device does not exist")
