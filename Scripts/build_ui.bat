@echo off
setlocal

rem Build the UI test image and start the `ui` service (keeps container running)
pushd "%~dp0.." >nul || (echo Failed to change directory & exit /b 1)

docker compose -f docker\docker-compose.yml build ui
docker compose -f docker\docker-compose.yml up -d ui
docker compose -f docker\docker-compose.yml ps ui

popd >nul
endlocal
