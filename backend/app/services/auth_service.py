from fastapi import HTTPException, status

from app.core.security import create_access_token, hash_password, verify_password
from app.models.user import User
from app.repositories.user_repository import UserRepository


class AuthService:
    def __init__(self, user_repository: UserRepository) -> None:
        self.user_repository = user_repository

    def authenticate(self, *, email: str, password: str) -> str:
        user = self.user_repository.get_by_email(email)
        if user is None or not user.is_active or not verify_password(password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return create_access_token(user.id)

    def ensure_initial_admin(self, *, email: str, password: str) -> User:
        existing_user = self.user_repository.get_by_email(email)
        if existing_user is not None:
            return existing_user
        return self.user_repository.create(
            email=email,
            hashed_password=hash_password(password),
            full_name="NOC Administrator",
        )
