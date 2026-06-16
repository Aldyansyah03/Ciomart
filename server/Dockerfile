# Use the official Dart SDK image to build the app
FROM dart:stable AS build

# Set the working directory
WORKDIR /app

# Copy pubspec files and resolve dependencies
COPY pubspec.* ./
RUN dart pub get

# Copy the entire server source code
COPY . .

# Precompile the application
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# Build production image using debian-slim
FROM debian:stable-slim

# Copy the compiled binary from build stage
COPY --from=build /app/bin/server /app/bin/server

# Set default port
ENV PORT=8082

# Expose port
EXPOSE 8082

# Run the server
CMD ["/app/bin/server"]
