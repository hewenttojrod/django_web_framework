## Frontend build stage (produce compiled assets)
FROM node:18-bullseye AS node-build
WORKDIR /build

# Ensure system build tools are available for native node modules
RUN apt-get update \
       && apt-get install -y --no-install-recommends \
              python3 \
              build-essential \
              make \
              g++ \
              ca-certificates \
       && rm -rf /var/lib/apt/lists/*

# Copy the taskboard frontend sources and config
COPY core/workspace/taskboard ./taskboard
WORKDIR /build/taskboard

# Install Node dependencies and build assets (use `npm ci` when a lockfile exists)
RUN if [ -f package-lock.json ] ; then \
                     npm ci --silent ; \
              else \
                     npm install --silent ; \
              fi

# Increase Node.js heap for large builds
ENV NODE_OPTIONS=--max_old_space_size=8192
RUN npm run build

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

# Install Node.js (needed for Tailwind CLI in the web container)
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl gnupg ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

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

# Copy built frontend assets from node-build stage into the Python image
COPY --from=node-build /build/taskboard/static/taskboard/dist /app/core/workspace/taskboard/static/taskboard/dist

EXPOSE 8000

CMD ["/bin/bash", "/app/docker/entrypoint.sh"]
