from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.location import Location, LocationType


class LocationRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def create(self, location: Location) -> Location:
        self.db.add(location)
        self.db.commit()
        self.db.refresh(location)
        return location

    def get(self, location_id: str) -> Location | None:
        return self.db.get(Location, location_id)

    def list(
        self,
        *,
        search: str | None = None,
        location_type: LocationType | None = None,
        parent_location_id: str | None = None,
        page: int = 1,
        page_size: int = 25,
    ) -> tuple[list[Location], int]:
        statement = select(Location)
        count_statement = select(func.count()).select_from(Location)

        filters = []
        if search:
            pattern = f"%{search}%"
            filters.append(or_(Location.location_name.ilike(pattern), Location.id.ilike(pattern)))
        if location_type:
            filters.append(Location.location_type == location_type)
        if parent_location_id:
            filters.append(Location.parent_location_id == parent_location_id)

        for filter_clause in filters:
            statement = statement.where(filter_clause)
            count_statement = count_statement.where(filter_clause)

        total = self.db.scalar(count_statement) or 0
        items = self.db.scalars(
            statement.order_by(Location.created_at.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
        ).all()
        return list(items), total

    def update(self, location: Location, values: dict[str, object]) -> Location:
        for key, value in values.items():
            setattr(location, key, value)
        self.db.commit()
        self.db.refresh(location)
        return location

    def delete(self, location: Location) -> None:
        self.db.delete(location)
        self.db.commit()
