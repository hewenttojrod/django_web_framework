@echo off
REM Run TaskBoard migrations (makemigrations for taskboard app, then migrate)
SETLOCAL

REM If a virtualenv activation script exists at ../venv, activate it
IF EXIST "%~dp0..\venv\Scripts\activate.bat" (
  call "%~dp0..\venv\Scripts\activate.bat"
)

REM Ensure DJANGO_SETTINGS_MODULE is set
IF "%DJANGO_SETTINGS_MODULE%"=="" SET DJANGO_SETTINGS_MODULE=core.settings

REM Run makemigrations for taskboard app
python "%~dp0..\manage.py" makemigrations taskboard
IF ERRORLEVEL 1 (
  echo Makemigrations failed.
  EXIT /B 1
)

REM Apply migrations
python "%~dp0..\manage.py" migrate
IF ERRORLEVEL 1 (
  echo Migrate failed.
  EXIT /B 1
)

ENDLOCAL
echo Migrations completed successfully.
pause
