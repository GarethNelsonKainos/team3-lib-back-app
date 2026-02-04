#!/usr/bin/env bash
set -euo pipefail

# Apply migrations 004-007 (if present) then seed development data.
# Usage: ./scripts/apply_remaining_migrations.sh

MIG_DIR="src/database/migrations"
SEED_FILE="/migrations/development_seed.sql"

# ensure container is up when using docker compose flow from earlier instructions
if [ -f docker-compose.yml ]; then
  echo "Using docker compose container 'db' if present..."
  docker compose up -d db || true
  echo "Waiting for Postgres..."
  until docker compose exec -T db pg_isready -U library >/dev/null 2>&1; do sleep 1; done
  echo "Applying remaining migrations inside container..."
  for f in $MIG_DIR/00{4,5,6,7}_*.sql; do
    if [ -f "$f" ]; then
      echo "---- Running $f"
      docker compose exec -T db psql -v ON_ERROR_STOP=1 -U library -d library_dev -f "/migrations/$(basename $f)"
    fi
  done
  if [ -f src/database/development_seed.sql ]; then
    echo "---- Applying seed"
    docker compose exec -T db psql -v ON_ERROR_STOP=1 -U library -d library_dev -f /migrations/development_seed.sql
  fi
else
  echo "No docker-compose.yml found. Running migrations locally against psql on host."
  for f in $MIG_DIR/00{4,5,6,7}_*.sql; do
    if [ -f "$f" ]; then
      echo "---- Running $f"
      psql -h 127.0.0.1 -U $USER -d library_dev -f "$f"
    fi
  done
  if [ -f src/database/development_seed.sql ]; then
    echo "---- Applying seed"
    psql -h 127.0.0.1 -U $USER -d library_dev -f src/database/development_seed.sql
  fi
fi

echo "Done."
