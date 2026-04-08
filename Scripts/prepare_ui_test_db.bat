@echo off
set COMPOSE_FILE=docker\docker-compose.yml
docker compose -f "%COMPOSE_FILE%" up -d db web_test
docker compose -f "%COMPOSE_FILE%" exec -T web_test bash -lc "rm -f /app/test_db.sqlite3 || true && python manage.py migrate --noinput --settings=web_core.settings_test"
