from pathlib import Path

from .settings import *  # noqa: F403,F401

# Use a lightweight sqlite DB for UI test runs. This file is intended to be
# used with `python manage.py migrate --settings=core.settings_test` or by
# passing `--settings=core.settings_test` to Django commands when preparing
# an isolated test DB for Playwright UI tests.

BASE_DIR = Path(__file__).resolve().parent.parent

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": str(BASE_DIR / "test_db.sqlite3"),
    }
}

# Allow all hosts for containerized test runs
ALLOWED_HOSTS = ["*"]
# Mark this settings file as used for UI test runs so test-only utilities can enable
# themselves (e.g. the `flush_db_for_tests` endpoint below).
TESTING = True
