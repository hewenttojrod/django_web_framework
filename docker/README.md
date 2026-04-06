# Docker helper files

Run the services from the project root with:

```bash
docker-compose -f docker/docker-compose.yml up --build
```

This will start MySQL, Redis, and the Django development server on port 8000.

Edit `docker/.env.sample` for environment variables and copy it to `.env` if you want to mount env vars into the container.
