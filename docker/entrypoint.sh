#!/usr/bin/env bash
set -e

# Simple wait-for-host:port loop
wait_for() {
  host="$1"
  port="$2"
  echo "Waiting for $host:$port..."
  until nc -z "$host" "$port" >/dev/null 2>&1; do
    sleep 1
  done
}

DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-3306}

wait_for "$DB_HOST" "$DB_PORT"

echo "Applying migrations and collecting static files..."
# Make migrations (if there are model changes), apply migrations and collect static files
# `makemigrations` is safe to run in dev containers; it will exit 0 if there are no changes.
python manage.py makemigrations --noinput || true
python manage.py migrate --noinput
python manage.py collectstatic --noinput || true

# Optionally create a superuser non-interactively when the following env vars are set:
# DJANGO_SUPERUSER_USERNAME, DJANGO_SUPERUSER_EMAIL, DJANGO_SUPERUSER_PASSWORD
if [ -n "${DJANGO_SUPERUSER_USERNAME:-}" ] && [ -n "${DJANGO_SUPERUSER_EMAIL:-}" ] && [ -n "${DJANGO_SUPERUSER_PASSWORD:-}" ]; then
  echo "Ensuring superuser ${DJANGO_SUPERUSER_USERNAME} exists..."
  python - <<PY
from django.contrib.auth import get_user_model
from django.core.management import call_command
import os
import django
django.setup()
User = get_user_model()
username = os.environ.get('DJANGO_SUPERUSER_USERNAME')
email = os.environ.get('DJANGO_SUPERUSER_EMAIL')
password = os.environ.get('DJANGO_SUPERUSER_PASSWORD')
if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username=username, email=email, password=password)
else:
    print('Superuser already exists')
PY
fi

# Execute the container command (e.g., gunicorn) so the entrypoint can run migrations
# and then hand off to the requested process. This preserves Docker Compose's
# ability to override the command while ensuring migrations run first.
exec "$@"
