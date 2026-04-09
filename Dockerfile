FROM python:3.12-slim AS base

# Security: run as non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

# Install dependencies first (layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY app.py .

# Switch to non-root user
USER appuser

EXPOSE 5000

ENV FLASK_ENV=production
ENV APP_VERSION=1.0.0

CMD ["python", "app.py"]
