#!/usr/bin/env bash
set -euo pipefail

# Run migrations inside the postgres container in lexicographic order.
# Usage: ./scripts/run_migrations.sh

COMPOSE_PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Wait for container to be healthy
echo "Starting containers..."
docker compose up -d db

echo "Waiting for Postgres to be ready..."
until docker compose exec -T db pg_isready -U library >/dev/null 2>&1; do
  sleep 1
done

echo "Running migrations..."
# Execute all *.sql files in /migrations in sorted order
docker compose exec -T db bash -lc "for f in /migrations/*.sql; do echo "---- Running $f"; psql -v ON_ERROR_STOP=1 -U library -d library_dev -f \"$f\"; done"

echo "Migrations completed."

echo "You can run the smoke checks with: docker compose exec -T db psql -U library -d library_dev -f /migrations/check_smoke.sql"
