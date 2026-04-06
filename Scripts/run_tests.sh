#!/usr/bin/env bash
set -euo pipefail
# Run unit tests (pytest) and optionally UI tests in Docker
# Run unit tests inside docker-compose 'web_test' service if docker is available,
# otherwise fall back to local pytest
if command -v docker-compose >/dev/null 2>&1 || command -v docker >/dev/null 2>&1; then
  echo "Running unit tests inside docker-compose service 'web_test'"
  docker-compose -f docker/docker-compose.yml run --rm web_test python -m pytest -q || { echo "Unit tests inside container failed"; exit 1; }
else
  echo "docker-compose not found - running pytest locally"
  if [ -f "requirements.txt" ]; then
    python -m pip install --upgrade pip >/dev/null 2>&1 || true
    python -m pip install -r requirements.txt >/dev/null 2>&1 || true
  fi
  python -m pytest -q || { echo "Local unit tests failed"; exit 1; }
fi

# By default run UI tests; set SKIP_UI_TESTS=1 to skip them
if [ "${SKIP_UI_TESTS:-0}" = "1" ]; then
  echo "Skipping UI tests because SKIP_UI_TESTS=1"
else
  echo "Running UI tests via Scripts/run_ui_tests_docker.bat"
  # on *nix we can call the batch via cmd.exe or run the script directly if available
  if command -v bash >/dev/null 2>&1; then
    bash Scripts/run_ui_tests_docker.bat || { echo "UI tests failed"; exit 1; }
  else
    cmd.exe /c Scripts\\run_ui_tests_docker.bat || { echo "UI tests failed"; exit 1; }
  fi
fi

echo "All requested tests passed."
