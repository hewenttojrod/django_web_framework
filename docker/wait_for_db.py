#!/usr/bin/env python3
"""Simple helper that waits for the configured DB host/port to accept TCP connections.

This avoids Django starting before MySQL is ready when running via docker-compose.
"""

import os
import socket
import sys
import time


def wait_for(host, port, timeout=60, interval=1):
    deadline = time.time() + timeout
    while True:
        try:
            with socket.create_connection((host, int(port)), timeout=3):
                return True
        except Exception:
            if time.time() > deadline:
                return False
            time.sleep(interval)


def main():
    host = os.environ.get("DB_HOST", "db")
    port = os.environ.get("DB_PORT", "3306")
    timeout = int(os.environ.get("DB_WAIT_TIMEOUT", "60"))
    sys.stdout.write(f"Waiting for DB at {host}:{port} (timeout {timeout}s)...\n")
    sys.stdout.flush()
    ok = wait_for(host, port, timeout=timeout)
    if not ok:
        sys.stderr.write(f"Timed out waiting for DB at {host}:{port}\n")
        sys.exit(1)
    sys.stdout.write("DB is available — continuing.\n")


if __name__ == "__main__":
    main()
