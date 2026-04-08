# STAGE 1: Build the application
FROM docker.io/library/gradle:8-jdk17 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src

# Build the shadowJar or executable jar (skipping tests to speed up the build)
RUN gradle build -x test --no-daemon

# STAGE 2: Run the application
FROM docker.io/library/openjdk:17-slim

# Set working directory
WORKDIR /app

# Copy the compiled JAR from the build stage
# Note: The jar name usually follows the pattern 'project-name-all.jar' or 'project-name.jar'
# We use a wildcard to capture it regardless of the exact version/name
COPY --from=build /home/gradle/src/build/libs/*.jar app.jar

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
