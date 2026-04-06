@echo off

echo Recreating test sqlite DB inside the web_test container using core.settings_test

REM Remove existing test DB and run migrations using the test settings in web_test
docker exec web_test bash -lc "rm -f /app/test_db.sqlite3 || true && python manage.py migrate --noinput --settings=core.settings_test"

if %ERRORLEVEL% NEQ 0 (
  echo Failed to prepare test DB
  exit /b %ERRORLEVEL%
)

echo Test sqlite DB prepared at /app/test_db.sqlite3 inside the web container.
