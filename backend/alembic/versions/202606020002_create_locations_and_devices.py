"""create locations and devices

Revision ID: 202606020002
Revises: 202606020001
Create Date: 2026-06-02 00:02:00.000000
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = "202606020002"
down_revision: Union[str, None] = "202606020001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

location_type = postgresql.ENUM(
    "CORE", "POP", "TOWER", "VILLAGE", "OLT_ROOM", name="locationtype", create_type=False
)
device_vendor = postgresql.ENUM(
    "MikroTik", "Ubiquiti", "Huawei", "VSOL", "BDCOM", "Cisco", "Generic", name="devicevendor", create_type=False
)
device_type = postgresql.ENUM(
    "ROUTER", "SWITCH", "OLT", "ONU", "TOWER", "ACCESS_POINT", "SERVER", name="devicetype", create_type=False
)
device_status = postgresql.ENUM("ONLINE", "OFFLINE", "UNKNOWN", name="devicestatus", create_type=False)


def upgrade() -> None:
    bind = op.get_bind()
    location_type.create(bind, checkfirst=True)
    device_vendor.create(bind, checkfirst=True)
    device_type.create(bind, checkfirst=True)
    device_status.create(bind, checkfirst=True)

    op.create_table(
        "locations",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("location_name", sa.String(length=255), nullable=False),
        sa.Column("location_type", location_type, nullable=False),
        sa.Column("latitude", sa.Float(), nullable=True),
        sa.Column("longitude", sa.Float(), nullable=True),
        sa.Column("parent_location_id", sa.String(length=36), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["parent_location_id"], ["locations.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_locations_location_name"), "locations", ["location_name"], unique=False)
    op.create_index(op.f("ix_locations_location_type"), "locations", ["location_type"], unique=False)
    op.create_index(op.f("ix_locations_parent_location_id"), "locations", ["parent_location_id"], unique=False)

    op.create_table(
        "devices",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("device_name", sa.String(length=255), nullable=False),
        sa.Column("hostname", sa.String(length=255), nullable=True),
        sa.Column("vendor", device_vendor, nullable=False),
        sa.Column("device_type", device_type, nullable=False),
        sa.Column("ip_address", sa.String(length=45), nullable=False),
        sa.Column("location_id", sa.String(length=36), nullable=True),
        sa.Column("parent_device_id", sa.String(length=36), nullable=True),
        sa.Column("status", device_status, nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["location_id"], ["locations.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["parent_device_id"], ["devices.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_devices_device_name"), "devices", ["device_name"], unique=False)
    op.create_index(op.f("ix_devices_hostname"), "devices", ["hostname"], unique=False)
    op.create_index(op.f("ix_devices_vendor"), "devices", ["vendor"], unique=False)
    op.create_index(op.f("ix_devices_device_type"), "devices", ["device_type"], unique=False)
    op.create_index(op.f("ix_devices_ip_address"), "devices", ["ip_address"], unique=True)
    op.create_index(op.f("ix_devices_location_id"), "devices", ["location_id"], unique=False)
    op.create_index(op.f("ix_devices_parent_device_id"), "devices", ["parent_device_id"], unique=False)


def downgrade() -> None:
    op.drop_index(op.f("ix_devices_parent_device_id"), table_name="devices")
    op.drop_index(op.f("ix_devices_location_id"), table_name="devices")
    op.drop_index(op.f("ix_devices_ip_address"), table_name="devices")
    op.drop_index(op.f("ix_devices_device_type"), table_name="devices")
    op.drop_index(op.f("ix_devices_vendor"), table_name="devices")
    op.drop_index(op.f("ix_devices_hostname"), table_name="devices")
    op.drop_index(op.f("ix_devices_device_name"), table_name="devices")
    op.drop_table("devices")

    op.drop_index(op.f("ix_locations_parent_location_id"), table_name="locations")
    op.drop_index(op.f("ix_locations_location_type"), table_name="locations")
    op.drop_index(op.f("ix_locations_location_name"), table_name="locations")
    op.drop_table("locations")

    bind = op.get_bind()
    device_status.drop(bind, checkfirst=True)
    device_type.drop(bind, checkfirst=True)
    device_vendor.drop(bind, checkfirst=True)
    location_type.drop(bind, checkfirst=True)
