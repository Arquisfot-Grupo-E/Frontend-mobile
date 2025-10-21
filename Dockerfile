# Dockerfile for building Flutter Android APK
FROM ghcr.io/cirruslabs/flutter:stable

# Install Android SDK dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the Flutter project
COPY . .

# Get dependencies
RUN flutter pub get

# Build the APK
CMD ["flutter", "build", "apk", "--release"]
