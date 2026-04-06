@echo off
REM Run Django makemigrations and migrate inside Docker only
REM Usage: Scripts\run_migration.bat [manage.py args]

SETLOCAL

set COMPOSE_FILE=docker\docker-compose.yml

if not exist "%COMPOSE_FILE%" (
    echo ERROR: %COMPOSE_FILE% not found. This script requires the repository Docker Compose setup.
    exit /b 2
)

docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker not found in PATH. Install Docker and ensure 'docker' is available.
    exit /b 3
)

set "WEB_ID="
for /f "usebackq tokens=*" %%i in (`docker compose -f "%COMPOSE_FILE%" ps -q web 2^>nul`) do set WEB_ID=%%i

if defined WEB_ID (
    echo Executing commands inside running 'web' container...
    docker compose -f "%COMPOSE_FILE%" exec web python manage.py makemigrations %*
    if errorlevel 1 (
        echo makemigrations failed with exit code %errorlevel%
        exit /b %errorlevel%
    )
    docker compose -f "%COMPOSE_FILE%" exec web python manage.py migrate %*
    if errorlevel 1 (
        echo migrate failed with exit code %errorlevel%
        exit /b %errorlevel%
    )
) else (
    echo No running 'web' container. Starting one-off container with 'run --rm'...
    docker compose -f "%COMPOSE_FILE%" run --rm web python manage.py makemigrations %*
    if errorlevel 1 (
        echo makemigrations failed with exit code %errorlevel%
        exit /b %errorlevel%
    )
    docker compose -f "%COMPOSE_FILE%" run --rm web python manage.py migrate %*
    if errorlevel 1 (
        echo migrate failed with exit code %errorlevel%
        exit /b %errorlevel%
    )
)

echo.
echo Migrations completed inside Docker.
ENDLOCAL
exit /b 0
