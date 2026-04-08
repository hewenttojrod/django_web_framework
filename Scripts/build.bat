@echo off
pushd "%~dp0.."
docker compose -f docker\docker-compose.yml build
docker compose -f docker\docker-compose.yml up -d
docker compose -f docker\docker-compose.yml ps
popd
