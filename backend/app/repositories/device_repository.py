from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.models.device import Device, DeviceType, DeviceVendor


class DeviceRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def create(self, device: Device) -> Device:
        self.db.add(device)
        self.db.commit()
        self.db.refresh(device)
        return device

    def get(self, device_id: str) -> Device | None:
        return self.db.get(Device, device_id)

    def get_by_ip(self, ip_address: str) -> Device | None:
        statement = select(Device).where(Device.ip_address == ip_address)
        return self.db.scalar(statement)

    def list(
        self,
        *,
        search: str | None = None,
        vendor: DeviceVendor | None = None,
        device_type: DeviceType | None = None,
        location_id: str | None = None,
        page: int = 1,
        page_size: int = 25,
        sort_by: str = "created_at",
        sort_dir: str = "desc",
    ) -> tuple[list[Device], int]:
        statement = select(Device)
        count_statement = select(func.count()).select_from(Device)

        filters = []
        if search:
            pattern = f"%{search}%"
            filters.append(
                or_(
                    Device.device_name.ilike(pattern),
                    Device.hostname.ilike(pattern),
                    Device.ip_address.ilike(pattern),
                )
            )
        if vendor:
            filters.append(Device.vendor == vendor)
        if device_type:
            filters.append(Device.device_type == device_type)
        if location_id:
            filters.append(Device.location_id == location_id)

        for filter_clause in filters:
            statement = statement.where(filter_clause)
            count_statement = count_statement.where(filter_clause)

        sort_column = getattr(Device, sort_by, Device.created_at)
        if sort_dir.lower() == "asc":
            statement = statement.order_by(sort_column.asc())
        else:
            statement = statement.order_by(sort_column.desc())

        total = self.db.scalar(count_statement) or 0
        items = self.db.scalars(statement.offset((page - 1) * page_size).limit(page_size)).all()
        return list(items), total

    def update(self, device: Device, values: dict[str, object]) -> Device:
        for key, value in values.items():
            setattr(device, key, value)
        self.db.commit()
        self.db.refresh(device)
        return device

    def delete(self, device: Device) -> None:
        self.db.delete(device)
        self.db.commit()
