@echo off
setlocal

REM Move to repository root (parent of this Scripts folder)
cd /d "%~dp0.."

set COMPOSE_FILE=docker\docker-compose.yml

echo Running tests inside web_test container (passes any args through)...
echo Running tests with coverage inside the web_test service...
docker compose -f "%COMPOSE_FILE%" exec -T web_test bash -lc "python -m pytest --maxfail=1 --disable-warnings -q --cov=core --cov-report=term-missing" %*

echo To rebuild the image (if you changed dependencies), run:
echo    docker compose -f "%COMPOSE_FILE%" build --no-cache web

endlocal
