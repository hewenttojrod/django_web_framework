@echo off
REM Run unit tests (pytest) and optionally UI tests in Docker
echo Running unit tests inside Docker 'web_test' service if available...
where docker-compose >nul 2>&1
if ERRORLEVEL 1 (
  where docker >nul 2>&1
)
if ERRORLEVEL 1 (
  echo Docker not found - falling back to local pytest
  python -m pip install --upgrade pip >nul 2>&1
  if exist requirements.txt (
    python -m pip install -r requirements.txt >nul 2>&1
  )
  python -m pytest -q
  if ERRORLEVEL 1 (
    echo Unit tests FAILED. Aborting.
    exit /b 1
  )
) else (
  echo Running inside docker-compose service 'web_test' using docker-compose -f docker\docker-compose.yml
  docker-compose -f docker\docker-compose.yml run --rm web_test python -m pytest -q
  if ERRORLEVEL 1 (
    echo Unit tests inside container FAILED. Aborting.
    exit /b 1
  )
)

REM By default run UI tests; set SKIP_UI_TESTS=1 to skip UI tests
if "%SKIP_UI_TESTS%"=="1" (
  echo Skipping UI tests because SKIP_UI_TESTS=1
) else (
  echo Running UI tests via Scripts\run_ui_tests_docker.bat
  call Scripts\run_ui_tests_docker.bat
  if ERRORLEVEL 1 (
    echo UI tests FAILED. Aborting.
    exit /b 1
  )
)

echo All requested tests passed.
exit /b 0
