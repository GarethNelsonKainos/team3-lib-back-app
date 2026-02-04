#!/bin/bash
# Run all migrations in order on local PostgreSQL
# Usage: ./scripts/run_local_migrations.sh

set -e

# Configuration - adjust these for your local setup
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-$(whoami)}"
DB_NAME="${DB_NAME:-library_dev}"

MIGRATIONS_DIR="database/migrations"

echo "================================================"
echo "Library System - Database Migration Runner"
echo "================================================"
echo "Host: $DB_HOST:$DB_PORT"
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "================================================"

# Check if psql is available
if ! command -v psql &> /dev/null; then
    echo "Error: psql command not found. Please install PostgreSQL client."
    exit 1
fi

# Check connection
echo "Testing database connection..."
if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" > /dev/null 2>&1; then
    echo "Error: Cannot connect to database. Check your credentials and that PostgreSQL is running."
    exit 1
fi
echo "Connection successful!"
echo ""

# Get list of migration files sorted by name
MIGRATION_FILES=$(find "$MIGRATIONS_DIR" -name "*.sql" -type f | sort)

if [ -z "$MIGRATION_FILES" ]; then
    echo "No migration files found in $MIGRATIONS_DIR"
    exit 0
fi

echo "Found migration files:"
echo "$MIGRATION_FILES" | while read -r file; do
    echo "  - $(basename "$file")"
done
echo ""

# Run each migration
FAILED=0
for migration in $MIGRATION_FILES; do
    filename=$(basename "$migration")
    echo "Running: $filename"
    
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$migration" 2>&1; then
        echo "✓ $filename completed"
    else
        echo "✗ $filename FAILED"
        FAILED=1
        break
    fi
    echo ""
done

if [ $FAILED -eq 0 ]; then
    echo "================================================"
    echo "All migrations completed successfully!"
    echo "================================================"
else
    echo "================================================"
    echo "Migration failed! Check the error above."
    echo "================================================"
    exit 1
fi
