# ISP Network Monitoring System

Production-grade ISP Network Operations Center platform built phase by phase.

## Phase 1 Scope

Phase 1 establishes the foundation only:

- FastAPI backend project layout with Clean Architecture boundaries.
- PostgreSQL connection through SQLAlchemy.
- Alembic migration for the initial single-user authentication table.
- JWT login and `/auth/me` session endpoint.
- Secure password hashing with Passlib bcrypt.
- Flutter 3 base app with Riverpod, Go Router, responsive login, authenticated dashboard shell, and WebSocket-ready service.
- Dockerfiles and Docker Compose for PostgreSQL, backend, and Flutter web frontend.

Future monitoring, alerting, topology, SNMP, MikroTik, ICMP, notifications, and outage engines are intentionally deferred to later phases.

## Architecture

The backend separates HTTP routes, schemas, repositories, services, models, and infrastructure configuration. API routes depend on services, services depend on repositories, and repositories own SQLAlchemy persistence.

The frontend separates core app concerns from feature modules. Riverpod owns application state, Go Router controls authenticated navigation, Dio handles API calls, and secure storage persists the JWT.

## Folder Structure

```text
backend/
  alembic/
  app/
    api/
    core/
    db/
    models/
    repositories/
    schemas/
    services/
    tests/
frontend/
  lib/
    src/
      core/
      features/
docker-compose.yml
```

## Backend Code

Key files:

- `backend/app/main.py`
- `backend/app/core/config.py`
- `backend/app/core/security.py`
- `backend/app/db/session.py`
- `backend/app/repositories/user_repository.py`
- `backend/app/services/auth_service.py`

## Database Models

Phase 1 includes the `users` table only:

- `id`
- `email`
- `hashed_password`
- `full_name`
- `is_active`
- `created_at`
- `updated_at`

Migration: `backend/alembic/versions/202606020001_create_users_table.py`

## API Routes

- `GET /health`
- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`

## Flutter Screens

- `LoginScreen`
- `DashboardScreen`

## Flutter Services

- `AuthRepository`
- `TokenStorage`
- `RealtimeService`
- shared Dio API client

## WebSocket Integration

Phase 1 provides the Flutter `RealtimeService` and environment configuration. Backend WebSocket endpoints are planned for the realtime monitoring phase.

## Docker

```bash
docker compose up --build
```

Services:

- PostgreSQL on `5432`
- FastAPI on `8000`
- Flutter web on `3000`

Docker is not required for local Flutter development.

## Local Development

Backend:

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
alembic upgrade head
uvicorn app.main:app --reload
```

Frontend:

```bash
cd frontend
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Default development login:

- Email: `admin@example.com`
- Password: `ChangeMe123!`

## Testing Strategy

Phase 1 tests focus on contracts and app wiring:

- Backend health and auth route tests using FastAPI `TestClient`.
- Repository/service tests with a disposable PostgreSQL database in CI.
- Flutter widget tests for auth state, login form validation, and route redirects.
- Docker Compose smoke test for migration plus backend boot.

## Phase 2 Scope

Phase 2 adds production-ready Device Management and Location Management only.

Backend additions:

- `locations` table with parent-child hierarchy.
- `devices` table with vendor/type/status enums, unique IP address, location assignment, and parent-device hierarchy.
- Repository and service layers for both modules.
- Authenticated REST APIs for create, update, delete, get, list, search, filtering, sorting, pagination, and device bulk import.
- Alembic migration `202606020002_create_locations_and_devices.py`.

Frontend additions:

- Device list, detail, create, and edit screens.
- Location list, detail, create, and edit screens.
- Riverpod providers and repositories for Phase 2 API calls.
- Search, pagination, filters, sorting, and status badges.

## Phase 2 API Examples

Create location:

```http
POST /api/v1/locations
Authorization: Bearer <token>
Content-Type: application/json

{
  "location_name": "POP Hamirpur",
  "location_type": "POP",
  "latitude": 31.6862,
  "longitude": 76.5213,
  "parent_location_id": null
}
```

Create device:

```http
POST /api/v1/devices
Authorization: Bearer <token>
Content-Type: application/json

{
  "device_name": "Core Router 01",
  "hostname": "core-rtr-01",
  "vendor": "MikroTik",
  "device_type": "ROUTER",
  "ip_address": "10.0.0.1",
  "location_id": null,
  "parent_device_id": null,
  "status": "UNKNOWN",
  "description": "Primary core router"
}
```

List devices:

```http
GET /api/v1/devices?search=core&vendor=MikroTik&device_type=ROUTER&page=1&page_size=25
Authorization: Bearer <token>
```

Bulk import:

```http
POST /api/v1/devices/bulk-import
Authorization: Bearer <token>
Content-Type: application/json

{
  "devices": [
    {
      "device_name": "Tower A AP",
      "vendor": "Ubiquiti",
      "device_type": "ACCESS_POINT",
      "ip_address": "10.10.1.2"
    }
  ]
}
```

OpenAPI documentation is available at `/docs` when the backend is running.
