@echo off
REM Run TaskBoard migrations (makemigrations for taskboard app, then migrate)
SETLOCAL

pushd "%~dp0.." >nul || (
  echo Failed to change directory to repository root
  exit /b 1
)

set COMPOSE_FILE=docker\docker-compose.yml

REM Try to run migrations inside a running 'web' container, otherwise run a one-off container
for /f "usebackq tokens=*" %%i in (`docker compose -f "%COMPOSE_FILE%" ps -q web 2^>nul`) do set WEB_ID=%%i

if defined WEB_ID (
  echo Executing makemigrations and migrate inside running 'web' container...
  docker compose -f "%COMPOSE_FILE%" exec -T web python manage.py makemigrations taskboard_module
  if ERRORLEVEL 1 (
    echo Makemigrations failed.
    popd >nul
    endlocal
    EXIT /B 1
  )
  docker compose -f "%COMPOSE_FILE%" exec -T web python manage.py migrate
  if ERRORLEVEL 1 (
    echo Migrate failed.
    popd >nul
    endlocal
    EXIT /B 1
  )
) else (
  echo No running 'web' container; running one-off container to apply migrations...
  docker compose -f "%COMPOSE_FILE%" run --rm web python manage.py makemigrations taskboard_module
  if ERRORLEVEL 1 (
    echo Makemigrations failed.
    popd >nul
    endlocal
    EXIT /B 1
  )
  docker compose -f "%COMPOSE_FILE%" run --rm web python manage.py migrate
  if ERRORLEVEL 1 (
    echo Migrate failed.
    popd >nul
    endlocal
    EXIT /B 1
  )
)

popd >nul
endlocal
echo Migrations completed successfully (inside Docker).
