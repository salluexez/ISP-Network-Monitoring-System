FROM ghcr.io/cirruslabs/flutter:3.41.9 AS build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release \
    --dart-define=API_BASE_URL=/api/v1 \
    --dart-define=WEBSOCKET_URL=ws://localhost:8000/ws

FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
