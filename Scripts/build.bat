@echo off
rem Run from repo root to build Docker services defined in docker/docker-compose.yml
setlocal

rem Change to the repository root (script is in Scripts\)
pushd "%~dp0.." >nul || (
	echo Failed to change directory to repository root
	exit /b 1
)

rem Build images
docker compose -f docker\docker-compose.yml build

echo Starting containers (detached)...
docker compose -f docker\docker-compose.yml up -d
docker compose -f docker\docker-compose.yml ps

popd >nul
endlocal
