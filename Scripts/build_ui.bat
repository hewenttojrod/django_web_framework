@echo off
pushd "%~dp0.."
docker compose -f docker\docker-compose.yml build ui
docker compose -f docker\docker-compose.yml up -d ui
docker compose -f docker\docker-compose.yml ps ui
popd
