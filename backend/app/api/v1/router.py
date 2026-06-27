from fastapi import APIRouter

from app.api.v1.routes import auth, devices, locations

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(locations.router)
api_router.include_router(devices.router)
