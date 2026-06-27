        HEAD
FROM python:3.11-slim

WORKDIR /app

COPY . .

RUN apt-get update && apt-get install -y curl

RUN pip install -r requirements.txt

RUN useradd -m appuser
USER appuser

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
