@echo off
rem Run from repo root to build and start Docker services defined in docker/docker-compose.yml
setlocal

rem Change to the repository root (script is in Scripts\)
pushd "%~dp0.." >nul || (
	echo Failed to change directory to repository root
	exit /b 1
)

rem Build images and start containers in detached mode
docker compose -f docker\docker-compose.yml up --build -d

popd >nul
endlocal
