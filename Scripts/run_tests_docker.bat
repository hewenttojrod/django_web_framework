@echo off
cd /d "%~dp0.."
set COMPOSE_FILE=docker\docker-compose.yml
docker compose -f "%COMPOSE_FILE%" exec -T web_test bash -lc "python -m pytest --maxfail=1 --disable-warnings -q --cov=core --cov-report=term-missing" %*
