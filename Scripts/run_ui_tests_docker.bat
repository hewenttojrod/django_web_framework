@echo off
pushd "%~dp0.."
set COMPOSE_FILE=docker\docker-compose.yml
docker compose -f "%COMPOSE_FILE%" up -d db redis web_test ui
call Scripts\prepare_ui_test_db.bat
for /f "usebackq tokens=*" %%i in (`docker compose -f "%COMPOSE_FILE%" ps -q ui 2^>nul`) do set UI_CID=%%i
docker compose -f "%COMPOSE_FILE%" exec -T ui bash -lc "rm -rf /app/ui-tests/tests/tests || true; rm -rf /app/ui-tests/test-results || true"
docker cp ui-tests/tests/. %UI_CID%:/app/ui-tests/tests
docker cp ui-tests/playwright.config.mjs %UI_CID%:/app/ui-tests/playwright.config.mjs
docker compose -f "%COMPOSE_FILE%" exec -T ui bash -lc "cd /app/ui-tests && PLAYWRIGHT_BASE_URL=http://web-test:8000 npx --yes playwright test --workers=1 --reporter=html" %*
if exist ui-tests\test-results rmdir /s /q ui-tests\test-results
mkdir ui-tests\test-results
docker cp %UI_CID%:/app/ui-tests/test-results .\ui-tests
popd
