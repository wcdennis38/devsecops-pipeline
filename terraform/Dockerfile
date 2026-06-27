# Lightweight Python base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy application code
COPY app.py /app/

# Install dependencies (if you expand later)
RUN pip install --no-cache-dir flask

# Expose port
EXPOSE 5000

# Run application
CMD ["python", "app.py"]
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
