FROM python:3.11-slim

WORKDIR /app

# Install system dependencies (minimal + secure)
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (better layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user for security
RUN useradd -m appuser
RUN chown -R appuser:appuser /app

USER appuser

# Health check (must use full path safety in slim images)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start app
CMD ["python", "app/main.py"]
