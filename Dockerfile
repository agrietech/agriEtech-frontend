# Stage 1: Build Flutter Web Application
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Enable Flutter Web
RUN flutter config --enable-web

# Copy dependency definitions
COPY pubspec.yaml pubspec.lock ./

# Fetch Flutter dependencies
RUN flutter pub get

# Copy full application source code
COPY . .

# Build production web bundle
RUN flutter build web --release --pwa-strategy=none

# Stage 2: Production NGINX Alpine Runtime (< 25MB)
FROM nginx:alpine AS runner

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built Flutter web bundle
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom NGINX configuration for Flutter SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3   CMD wget -qO- http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
