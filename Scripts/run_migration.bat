@echo off
SETLOCAL
set COMPOSE_FILE=docker\docker-compose.yml
set "WEB_ID="
for /f "usebackq tokens=*" %%i in (`docker compose -f "%COMPOSE_FILE%" ps -q web 2^>nul`) do set WEB_ID=%%i
if defined WEB_ID (
    docker compose -f "%COMPOSE_FILE%" exec web python manage.py makemigrations %*
    docker compose -f "%COMPOSE_FILE%" exec web python manage.py migrate %*
) else (
    docker compose -f "%COMPOSE_FILE%" run --rm web python manage.py makemigrations %*
    docker compose -f "%COMPOSE_FILE%" run --rm web python manage.py migrate %*
)
ENDLOCAL
