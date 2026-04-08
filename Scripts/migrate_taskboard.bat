@echo off
pushd "%~dp0.."
set COMPOSE_FILE=docker\docker-compose.yml
for /f "usebackq tokens=*" %%i in (`docker compose -f "%COMPOSE_FILE%" ps -q web 2^>nul`) do set WEB_ID=%%i
if defined WEB_ID (
  docker compose -f "%COMPOSE_FILE%" exec -T web python manage.py makemigrations taskboard
  docker compose -f "%COMPOSE_FILE%" exec -T web python manage.py migrate
) else (
  docker compose -f "%COMPOSE_FILE%" run --rm web python manage.py makemigrations taskboard
  docker compose -f "%COMPOSE_FILE%" run --rm web python manage.py migrate
)
popd
