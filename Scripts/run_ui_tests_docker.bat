@echo off
setlocal

rem Run Playwright UI tests inside the `ui` container. Ensure the `web` service is running.
pushd "%~dp0.." >nul || (echo Failed to change directory & exit /b 1)

set COMPOSE_FILE=docker\docker-compose.yml

echo Starting docker-compose services (detached) for tests (db, redis, web_test, ui)...
docker compose -f "%COMPOSE_FILE%" up -d db redis web_test ui
if %ERRORLEVEL% NEQ 0 (
	echo Failed to start required services
	popd >nul
	endlocal
	exit /b %ERRORLEVEL%
)

echo Preparing test sqlite DB inside the web_test service...
call Scripts\prepare_ui_test_db.bat
if %ERRORLEVEL% NEQ 0 (
	echo prepare_ui_test_db failed
	popd >nul
	endlocal
	exit /b %ERRORLEVEL%
)

echo Running Playwright tests in the 'ui' service (single worker)...
echo Cleaning old test directories inside the ui container and copying updated tests...

rem Determine the container id for the ui service
for /f "usebackq tokens=*" %%i in (`docker compose -f "%COMPOSE_FILE%" ps -q ui 2^>nul`) do set UI_CID=%%i
if not defined UI_CID (
	echo Could not determine ui container ID
	popd >nul
	endlocal
	exit /b 1
)

docker compose -f "%COMPOSE_FILE%" exec -T ui bash -lc "rm -rf /app/ui-tests/tests/tests || true; rm -rf /app/ui-tests/test-results || true"
docker cp ui-tests/tests/. %UI_CID%:/app/ui-tests/tests || echo Failed to copy ui-tests/tests into container
docker cp ui-tests/playwright.config.mjs %UI_CID%:/app/ui-tests/playwright.config.mjs 2>nul || echo No local playwright.config.mjs to copy

echo Running Playwright tests in the ui service against web_test...
docker compose -f "%COMPOSE_FILE%" exec -T ui bash -lc "cd /app/ui-tests && PLAYWRIGHT_BASE_URL=http://web-test:8000 npx --yes playwright test --workers=1 --reporter=html" %*
set RC=%ERRORLEVEL%

echo Copying test artifacts from the ui container to the host at ui-tests\test-results...
if exist ui-tests\test-results rmdir /s /q ui-tests\test-results
mkdir ui-tests\test-results 2>nul || rem ignore
docker cp %UI_CID%:/app/ui-tests/test-results .\ui-tests || echo Failed to copy test-results (they may not exist)
rem If docker created a nested test-results folder, move its contents up one level and remove the redundant folder
if exist ui-tests\test-results\test-results (
	echo Fixing nested test-results folder...
	move /Y ui-tests\test-results\test-results\* ui-tests\test-results >nul 2>nul || echo No files to move
	rmdir /S /Q ui-tests\test-results\test-results >nul 2>nul || echo Could not remove nested folder
)

rem Create or update a stable "last-run-latest" folder pointing to the most recent run
set NEWEST=
for /f "delims=" %%D in ('dir /b /ad /o-d ui-tests\test-results\last-run-* 2^>nul') do (
	set NEWEST=%%D
	goto :foundNewest
)
:foundNewest
if defined NEWEST (
	echo Exporting most recent run '%NEWEST%' to ui-tests\test-results\last-run-latest...
	if exist ui-tests\test-results\last-run-latest rmdir /S /Q ui-tests\test-results\last-run-latest >nul 2>nul || echo Could not remove existing last-run-latest
	xcopy /E /I /Y "ui-tests\test-results\%NEWEST%" "ui-tests\test-results\last-run-latest\" >nul 2>nul || echo Failed to copy latest run to last-run-latest
)

rem Ensure every test folder has step 000 and step 999 images; create placeholders if missing
for /D %%T in (ui-tests\test-results\last-run-*-*/\*) do (
	rem %%T includes trailing backslash; normalize
	set "TF=%%~fT"
	call :ensure_steps "%%~fT"
)

goto :afterEnsure

:ensure_steps
setlocal
set "TESTDIR=%~1"
if not exist "%TESTDIR%" (
	endlocal & goto :eof
)
rem Check for any file starting with 'step 000 -'
pushd "%TESTDIR%" >nul 2>nul || (endlocal & goto :eof)
set FOUND000=0
for %%F in ("step 000 - *") do (
	if exist "%%~fF" set FOUND000=1
)
set FOUND999=0
for %%G in ("step 999 - *") do (
	if exist "%%~fG" set FOUND999=1
)
if "%FOUND000%"=="0" (
	rem try to copy earliest step or final screenshot
	for /f "delims=" %%A in ('dir /b /o:n "step *.*" 2^>nul') do (
		copy /Y "%%A" "step 000 - initial-load-%DATE:~0,0%-%TIME:~0,0%.png" >nul 2>nul
		goto :created000
	)
	:created000
)
if "%FOUND999%"=="0" (
	rem prefer final-*.png
	for %%B in (final-*.png) do (
		copy /Y "%%~fB" "step 999 - final-%DATE:~0,0%-%TIME:~0,0%.png" >nul 2>nul
		goto :created999
	)
	rem fallback to any step file
	for /f "delims=" %%C in ('dir /b /o:-n "step *.*" 2^>nul') do (
		copy /Y "%%C" "step 999 - final-%DATE:~0,0%-%TIME:~0,0%.png" >nul 2>nul
		goto :created999
	)
	:created999
)
popd >nul 2>nul
endlocal & goto :eof

:afterEnsure

popd >nul
endlocal
exit /b %RC%
