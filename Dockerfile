# Stage 1: Build
FROM gradle:8-jdk21 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
# Build the application, skipping tests for speed
RUN gradle build --no-daemon -x test

# Stage 2: Run
FROM openjdk:21-slim
EXPOSE 8080
# Copy the built JAR from the builder stage
COPY --from=build /home/gradle/src/build/libs/*.jar /app/application.jar
ENTRYPOINT ["java", "-jar", "/app/application.jar"]

