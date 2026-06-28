        HEAD
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Upgrade pip for reliability
RUN pip install --no-cache-dir --upgrade pip

# Install Python dependencies first (better caching)
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ /app/app/
COPY main.py /app/main.py

# Create non-root user for security
RUN useradd -m appuser && chown -R appuser:appuser /app

HEALTHCHECK --interval=30s --timeout 5s --retries 3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["python", "app/main.py"]

FROM node:20-alpine

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

COPY . .

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --spider -q http://localhost:3000 || exit 1

CMD ["npm", "start"]
        628b635 (Add .dockerignore to prevent sensitive data leakage)
# Healthcheck (must work before user switch)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

USER appuser

EXPOSE 8080

# FIXED ENTRYPOINT PATH
CMD ["python", "/app/main.py"]
