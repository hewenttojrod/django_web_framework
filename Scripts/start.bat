@echo off
pushd "%~dp0.."
docker compose -f docker\docker-compose.yml up --build -d
popd
