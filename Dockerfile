FROM python:3.11-slim

WORKDIR /app

# Install only required system deps
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Copy ONLY dependency file first (better caching + safer)
COPY requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

# Copy ONLY application code (NOT everything)
COPY app/ /app/app/
COPY main.py /app/main.py

# Create non-root user (security hardening)
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["python", "app/main.py"]
