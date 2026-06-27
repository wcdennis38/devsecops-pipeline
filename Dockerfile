# Use official lightweight Node image
FROM node:20-alpine

# Create non-root user (fixes Trivy DS-0002)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy dependency files first (better caching)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application source
COPY . .

# Fix permissions for non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user (IMPORTANT)
USER appuser

# Expose app port (change if needed)
EXPOSE 3000

# Start application
CMD ["npm", "start"]
