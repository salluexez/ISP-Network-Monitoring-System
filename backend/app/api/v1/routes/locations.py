from typing import Annotated

from fastapi import APIRouter, Depends, Query, Response, status

from app.api.deps import get_current_user, get_location_repository
from app.models.location import LocationType
from app.models.user import User
from app.repositories.location_repository import LocationRepository
from app.schemas.location import LocationCreate, LocationListResponse, LocationResponse, LocationUpdate
from app.services.location_service import LocationService

router = APIRouter(prefix="/locations", tags=["locations"])


def get_location_service(
    repository: Annotated[LocationRepository, Depends(get_location_repository)],
) -> LocationService:
    return LocationService(repository)


@router.post(
    "",
    response_model=LocationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create location",
    openapi_extra={
        "requestBody": {
            "content": {
                "application/json": {
                    "example": {
                        "location_name": "POP Hamirpur",
                        "location_type": "POP",
                        "latitude": 31.6862,
                        "longitude": 76.5213,
                        "parent_location_id": None,
                    }
                }
            }
        }
    },
)
def create_location(
    payload: LocationCreate,
    service: Annotated[LocationService, Depends(get_location_service)],
    _: Annotated[User, Depends(get_current_user)],
) -> LocationResponse:
    return service.create(payload)


@router.get("", response_model=LocationListResponse, summary="List and search locations")
def list_locations(
    service: Annotated[LocationService, Depends(get_location_service)],
    _: Annotated[User, Depends(get_current_user)],
    search: str | None = Query(default=None, max_length=255),
    location_type: LocationType | None = None,
    parent_location_id: str | None = None,
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=25, ge=1, le=100),
) -> LocationListResponse:
    items, total = service.list(
        search=search,
        location_type=location_type,
        parent_location_id=parent_location_id,
        page=page,
        page_size=page_size,
    )
    return LocationListResponse(items=items, total=total, page=page, page_size=page_size)


@router.get("/{location_id}", response_model=LocationResponse, summary="Get location by id")
def get_location(
    location_id: str,
    service: Annotated[LocationService, Depends(get_location_service)],
    _: Annotated[User, Depends(get_current_user)],
) -> LocationResponse:
    return service.get(location_id)


@router.put("/{location_id}", response_model=LocationResponse, summary="Update location")
def update_location(
    location_id: str,
    payload: LocationUpdate,
    service: Annotated[LocationService, Depends(get_location_service)],
    _: Annotated[User, Depends(get_current_user)],
) -> LocationResponse:
    return service.update(location_id, payload)


@router.delete("/{location_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Delete location")
def delete_location(
    location_id: str,
    service: Annotated[LocationService, Depends(get_location_service)],
    _: Annotated[User, Depends(get_current_user)],
) -> Response:
    service.delete(location_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
