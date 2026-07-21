# Stage 1: Build Dart CLI
FROM dart:stable AS build
WORKDIR /app
COPY backend/pubspec.* ./
RUN dart pub get
COPY backend/ ./
RUN dart compile exe bin/toot.dart -o toot

# Stage 2: Final Run Image
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y \
    nginx \
    cron \
    sqlite3 \
    libsqlite3-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled native binary
COPY --from=build /app/toot /usr/local/bin/toot

# Copy static frontend files (moved to root in step 3)
COPY static_dart_build/ /var/www/html/

# Copy Nginx config
COPY config/nginx.conf /etc/nginx/sites-available/default
RUN rm -f /etc/nginx/sites-enabled/default && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create database volume directory
RUN mkdir -p /app/data && chmod 777 /app/data
VOLUME /app/data

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
