from __future__ import annotations

from fastapi import HTTPException, status

from app.models.location import Location, LocationType
from app.repositories.location_repository import LocationRepository
from app.schemas.location import LocationCreate, LocationUpdate


class LocationService:
    def __init__(self, repository: LocationRepository) -> None:
        self.repository = repository

    def create(self, payload: LocationCreate) -> Location:
        self._validate_parent(payload.parent_location_id)
        location = Location(**payload.model_dump())
        return self.repository.create(location)

    def get(self, location_id: str) -> Location:
        location = self.repository.get(location_id)
        if location is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Location not found")
        return location

    def list(
        self,
        *,
        search: str | None,
        location_type: LocationType | None,
        parent_location_id: str | None,
        page: int,
        page_size: int,
    ) -> tuple[list[Location], int]:
        return self.repository.list(
            search=search,
            location_type=location_type,
            parent_location_id=parent_location_id,
            page=page,
            page_size=page_size,
        )

    def update(self, location_id: str, payload: LocationUpdate) -> Location:
        location = self.get(location_id)
        values = payload.model_dump(exclude_unset=True)
        parent_location_id = values.get("parent_location_id")
        if parent_location_id is not None:
            if parent_location_id == location_id:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Location cannot parent itself")
            self._validate_parent(str(parent_location_id))
        return self.repository.update(location, values)

    def delete(self, location_id: str) -> None:
        self.repository.delete(self.get(location_id))

    def _validate_parent(self, parent_location_id: str | None) -> None:
        if parent_location_id is None:
            return
        if self.repository.get(parent_location_id) is None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Parent location does not exist")
