@echo off

echo Recreating test sqlite DB inside the web_test service using web_core.settings_test

set COMPOSE_FILE=docker\docker-compose.yml

rem Ensure db and web_test services are up
docker compose -f "%COMPOSE_FILE%" up -d db web_test
if %ERRORLEVEL% NEQ 0 (
  echo Failed to start required services
  exit /b %ERRORLEVEL%
)

REM Run migrations inside the web_test service
docker compose -f "%COMPOSE_FILE%" exec -T web_test bash -lc "rm -f /app/test_db.sqlite3 || true && python manage.py migrate --noinput --settings=web_core.settings_test"

if %ERRORLEVEL% NEQ 0 (
  echo Failed to prepare test DB
  exit /b %ERRORLEVEL%
)

echo Test sqlite DB prepared at /app/test_db.sqlite3 inside the web_test container.
