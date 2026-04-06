# TaskBoard (initialized)

The web UI will be available at http://localhost:8000 and MySQL at port 3306.

## A/B testing — tests

This repository includes a minimal A/B testing utility and two sets of tests so you
can run them side-by-side:

-- Django `unittest` style: `core.workspace.taskboard.tests` package (uses Django's `TestCase`).
-- `pytest` style: `core/workspace/taskboard/tests` package (standard `pytest`).

Files added/moved:

- `core/workspace/taskboard/ab_testing.py` — deterministic variant assignment helper.
- `core/workspace/taskboard/tests/` — test package containing both `unittest` and `pytest` tests.

Running the tests
-----------------

Run Django's test runner (uses settings from this project):

```bash
python manage.py test core.workspace.taskboard.tests
```

Run `pytest` (install `pytest` if needed):

```bash
pytest core/workspace/taskboard/tests -q
```

To run Django `TestCase` tests with `pytest` you need `pytest-django` installed. Install and run:

```bash
pip install pytest-django
pytest
```

Notes
-----
- The assignment is deterministic: the same `identifier` + `experiment` will
	always map to the same variant.
- If you prefer `pytest` for Django (e.g. `pytest-django`), install it and run
	`pytest` at repo root; it will collect both sets of tests.

