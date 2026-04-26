# 1. Use a slim image instead of the full Python image
FROM python:3.9-slim

# 2. Add appropriate labels
LABEL maintainer="FalakNaeem11"
LABEL version="1.0"
LABEL description="Optimized Sakila Flask Application"

# Install curl for the HEALTHCHECK
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 3. Create a non-root user for security
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Set working directory
WORKDIR /app

# 4. Copy requirements file first for Docker layer caching
COPY requirements.txt .

# 5. Use requirements.txt instead of individual RUN pip install commands
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Change ownership of files to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# 6. Do NOT hardcode sensitive environment variables (they should be injected via docker-compose or .env)

# 7. Expose only the required port (5000), removed unnecessary ports 3306 and 22
EXPOSE 5000

# 8. Add a HEALTHCHECK instruction to monitor the container status
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1

# Command to run the application
CMD ["python", "app.py"]
