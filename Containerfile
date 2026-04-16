FROM docker.io/library/eclipse-temurin:8-jdk-focal

# 1. Install Node.js 14
RUN apt-get update && apt-get install -y curl xz-utils \
    && curl -fsSL https://nodejs.org/dist/v14.17.0/node-v14.17.0-linux-x64.tar.xz -o node.tar.xz \
    && tar -xJf node.tar.xz -C /usr/local --strip-components=1 \
    && rm node.tar.xz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Setup Database Directory with correct permissions
RUN mkdir -p /app/data && chmod 777 /app/data

# 3. Copy build files first for caching
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle* .

RUN chmod +x gradlew

# 4. Copy the rest of the source
COPY . .

# 5. Build the shadowJar
RUN ./gradlew :backend:shadowJar --no-daemon

# 6. RUN COMMAND:
# We use the classpath (-cp) to ensure the SQLite driver is loaded properly.
# The Main class for this bot is io.ktor.server.netty.EngineMain.
CMD ["java", "-jar", "backend/build/libs/backend.jar"]
