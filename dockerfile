FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# SAFE: only dependency file
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# SAFE: only application code (no repo-wide copy)
COPY app/ /app/app/
COPY main.py /app/main.py

RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["python", "app/main.py"]
