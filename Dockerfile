# Use an official lightweight Python image
FROM docker.io/library/python:3.11-slim

# Set environment variables to ensure Python output is logged in real-time
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies (useful if the bot requires building C-extensions)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file first to leverage Podman layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Run the bot
# NOTE: If the bot's main startup script is named something other than 'main.py' 
# (e.g., 'bot.py' or 'app.py'), update the filename below accordingly.
CMD ["python", "main.py"]
