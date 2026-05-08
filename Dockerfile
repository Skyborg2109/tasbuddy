# Install Flutter and build the web app
FROM debian:latest AS build

# Cache bust - forces rebuild when changed: 2026-05-08
ARG CACHE_BUST=2026-05-08-v2

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Clone Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter

# Set Flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-download Flutter dependencies
RUN flutter doctor

# Copy project files
WORKDIR /app
COPY . .

# Build web
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Port setup for Railway
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
