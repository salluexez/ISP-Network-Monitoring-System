from datetime import datetime

from pydantic import BaseModel, Field, model_validator

from app.models.location import LocationType


class LocationBase(BaseModel):
    location_name: str = Field(min_length=1, max_length=255)
    location_type: LocationType
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    parent_location_id: str | None = None

    @model_validator(mode="after")
    def coordinates_must_be_pair(self) -> "LocationBase":
        if (self.latitude is None) ^ (self.longitude is None):
            raise ValueError("latitude and longitude must be provided together")
        return self


class LocationCreate(LocationBase):
    pass


class LocationUpdate(BaseModel):
    location_name: str | None = Field(default=None, min_length=1, max_length=255)
    location_type: LocationType | None = None
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    parent_location_id: str | None = None


class LocationResponse(LocationBase):
    id: str
    created_at: datetime

    model_config = {"from_attributes": True}


class LocationListResponse(BaseModel):
    items: list[LocationResponse]
    total: int
    page: int
    page_size: int
