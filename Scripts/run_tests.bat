@echo off
docker compose -f docker\docker-compose.yml exec -T web_test python -m pytest -q
if "%SKIP_UI_TESTS%"=="1" (
  echo Skipping UI tests because SKIP_UI_TESTS=1
) else (
  call Scripts\run_ui_tests_docker.bat
)
