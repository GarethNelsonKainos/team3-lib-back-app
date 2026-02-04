#!/bin/bash
# Backup the database to a SQL file
# Usage: ./scripts/backup_database.sh [output_file]

set -e

# Configuration
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-$(whoami)}"
DB_NAME="${DB_NAME:-library_dev}"

BACKUP_DIR="backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="${1:-$BACKUP_DIR/library_backup_$TIMESTAMP.sql}"

echo "================================================"
echo "Library System - Database Backup"
echo "================================================"
echo "Database: $DB_NAME"
echo "Output: $OUTPUT_FILE"
echo "================================================"

# Check if pg_dump is available
if ! command -v pg_dump &> /dev/null; then
    echo "Error: pg_dump command not found. Please install PostgreSQL client."
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Run backup
echo "Creating backup..."
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
    --no-owner \
    --no-privileges \
    --format=plain \
    --file="$OUTPUT_FILE"

# Compress if successful
if [ -f "$OUTPUT_FILE" ]; then
    FILESIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo ""
    echo "================================================"
    echo "Backup completed successfully!"
    echo "File: $OUTPUT_FILE"
    echo "Size: $FILESIZE"
    echo "================================================"
    
    # Optional: compress the backup
    read -p "Compress backup with gzip? (y/n): " compress
    if [ "$compress" = "y" ]; then
        gzip "$OUTPUT_FILE"
        echo "Compressed to: ${OUTPUT_FILE}.gz"
    fi
else
    echo "Error: Backup failed!"
    exit 1
fi
