from typing import Annotated

from fastapi import APIRouter, Depends, Query, Response, status

from app.api.deps import get_current_user, get_device_repository, get_location_repository
from app.models.device import DeviceType, DeviceVendor
from app.models.user import User
from app.repositories.device_repository import DeviceRepository
from app.repositories.location_repository import LocationRepository
from app.schemas.device import (
    DeviceBulkImportRequest,
    DeviceBulkImportResponse,
    DeviceCreate,
    DeviceListResponse,
    DeviceResponse,
    DeviceUpdate,
)
from app.services.device_service import DeviceService

router = APIRouter(prefix="/devices", tags=["devices"])


def get_device_service(
    device_repository: Annotated[DeviceRepository, Depends(get_device_repository)],
    location_repository: Annotated[LocationRepository, Depends(get_location_repository)],
) -> DeviceService:
    return DeviceService(device_repository, location_repository)


@router.post(
    "",
    response_model=DeviceResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create device",
    openapi_extra={
        "requestBody": {
            "content": {
                "application/json": {
                    "example": {
                        "device_name": "Core Router 01",
                        "hostname": "core-rtr-01",
                        "vendor": "MikroTik",
                        "device_type": "ROUTER",
                        "ip_address": "10.0.0.1",
                        "location_id": None,
                        "parent_device_id": None,
                        "status": "UNKNOWN",
                        "description": "Primary core router",
                    }
                }
            }
        }
    },
)
def create_device(
    payload: DeviceCreate,
    service: Annotated[DeviceService, Depends(get_device_service)],
    _: Annotated[User, Depends(get_current_user)],
) -> DeviceResponse:
    return service.create(payload)


@router.get("", response_model=DeviceListResponse, summary="List, search, filter, and sort devices")
def list_devices(
    service: Annotated[DeviceService, Depends(get_device_service)],
    _: Annotated[User, Depends(get_current_user)],
    search: str | None = Query(default=None, max_length=255),
    vendor: DeviceVendor | None = None,
    device_type: DeviceType | None = None,
    location_id: str | None = None,
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=25, ge=1, le=100),
    sort_by: str = Query(default="created_at", pattern="^(device_name|ip_address|created_at|updated_at|status)$"),
    sort_dir: str = Query(default="desc", pattern="^(asc|desc)$"),
) -> DeviceListResponse:
    items, total = service.list(
        search=search,
        vendor=vendor,
        device_type=device_type,
        location_id=location_id,
        page=page,
        page_size=page_size,
        sort_by=sort_by,
        sort_dir=sort_dir,
    )
    return DeviceListResponse(items=items, total=total, page=page, page_size=page_size)


@router.post("/bulk-import", response_model=DeviceBulkImportResponse, summary="Bulk import devices")
def bulk_import_devices(
    payload: DeviceBulkImportRequest,
    service: Annotated[DeviceService, Depends(get_device_service)],
    _: Annotated[User, Depends(get_current_user)],
) -> DeviceBulkImportResponse:
    created, failed = service.bulk_import(payload)
    return DeviceBulkImportResponse(created=created, failed=failed)


@router.get("/{device_id}", response_model=DeviceResponse, summary="Get device by id")
def get_device(
    device_id: str,
    service: Annotated[DeviceService, Depends(get_device_service)],
    _: Annotated[User, Depends(get_current_user)],
) -> DeviceResponse:
    return service.get(device_id)


@router.put("/{device_id}", response_model=DeviceResponse, summary="Update device")
def update_device(
    device_id: str,
    payload: DeviceUpdate,
    service: Annotated[DeviceService, Depends(get_device_service)],
    _: Annotated[User, Depends(get_current_user)],
) -> DeviceResponse:
    return service.update(device_id, payload)


@router.delete("/{device_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Delete device")
def delete_device(
    device_id: str,
    service: Annotated[DeviceService, Depends(get_device_service)],
    _: Annotated[User, Depends(get_current_user)],
) -> Response:
    service.delete(device_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
