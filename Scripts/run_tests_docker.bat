@echo off
setlocal

REM Move to repository root (parent of this Scripts folder)
cd /d "%~dp0.."

set COMPOSE_FILE=docker/docker-compose.yml

echo Running tests inside web container (passes any args through)...
echo Running tests with coverage for `core` inside web container...
docker compose -f "%COMPOSE_FILE%" run --rm web bash -lc "python -m pytest --maxfail=1 --disable-warnings -q --cov=core --cov-report=term-missing" %*

echo To rebuild the image (if you changed dependencies), run:
echo    docker compose -f "%COMPOSE_FILE%" build --no-cache web

endlocal
