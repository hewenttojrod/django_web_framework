## Frontend build removed
# Frontend assets should be built outside the Docker image (locally or in CI).
# This Dockerfile no longer installs Node or runs `npm install`/`npm run build`.

## Python runtime stage
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install build tools and libraries required to compile some Python packages
RUN apt-get update \
       && apt-get install -y --no-install-recommends \
              build-essential \
              default-libmysqlclient-dev \
              libmariadb-dev-compat \
              libmariadb-dev \
              pkg-config \
              libssl-dev \
              libffi-dev \
              default-mysql-client \
              python3-dev \
              netcat-openbsd \
              ca-certificates \
       && rm -rf /var/lib/apt/lists/*

# Note: Node.js installation removed. If Tailwind CLI is required inside the
# container, install Node.js on the host or build assets prior to building the
# Python image and copy the compiled assets into the image.

# Ensure build tools for Python wheels are available
RUN pip install --upgrade pip setuptools wheel

# Copy and install Python requirements before copying full source to leverage cache
COPY docker/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
RUN pip install --no-cache-dir pytest-cov coverage

# Copy application source
COPY . /app
COPY docker/entrypoint.sh /app/docker/entrypoint.sh
RUN chmod +x /app/docker/entrypoint.sh

# NOTE: frontend assets are expected to be built outside the Docker build
# and included in the repository (e.g. commit `static/taskboard_module/dist`).
# If you want the Docker build to include them, run the node build step before
# building the image and ensure `static/taskboard_module/dist` exists in the
# build context so it will be copied by the following (now-local) path:
# Note: frontend assets are mounted at runtime via docker-compose volumes
# or built into the image prior to building. The Dockerfile no longer copies
# local static assets at build time to avoid failing the build when they are
# not present in the context.

EXPOSE 8000

CMD ["/bin/bash", "/app/docker/entrypoint.sh"]
