from typing import Annotated

from fastapi import APIRouter, Depends

from app.api.deps import get_current_user, get_user_repository
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.schemas.auth import LoginRequest, TokenResponse, UserResponse
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])


def get_auth_service(
    user_repository: Annotated[UserRepository, Depends(get_user_repository)],
) -> AuthService:
    return AuthService(user_repository)


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, auth_service: Annotated[AuthService, Depends(get_auth_service)]) -> TokenResponse:
    token = auth_service.authenticate(email=payload.email, password=payload.password)
    return TokenResponse(access_token=token)


@router.get("/me", response_model=UserResponse)
def me(current_user: Annotated[User, Depends(get_current_user)]) -> User:
    return current_user
