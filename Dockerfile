FROM python:3.11-slim

WORKDIR /app

# Install system dependencies (minimal + secure)
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies first (better caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code (SAFE ONLY because .dockerignore exists)
COPY . .

# Create non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["python", "app/main.py"]
