#!/bin/bash
# Reset the database - drops and recreates all tables
# WARNING: This will delete ALL data!
# Usage: ./scripts/reset_database.sh

set -e

# Configuration
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-$(whoami)}"
DB_NAME="${DB_NAME:-library_dev}"

echo "================================================"
echo "Library System - Database Reset"
echo "================================================"
echo "WARNING: This will DELETE ALL DATA in $DB_NAME"
echo "================================================"
echo ""

# Confirmation prompt
read -p "Are you sure you want to reset the database? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Dropping all tables..."

psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" << 'EOF'
-- Drop all views first
DROP VIEW IF EXISTS v_dashboard_summary CASCADE;
DROP VIEW IF EXISTS v_borrowing_trends_monthly CASCADE;
DROP VIEW IF EXISTS v_borrowing_trends_daily CASCADE;
DROP VIEW IF EXISTS v_collection_utilization CASCADE;
DROP VIEW IF EXISTS v_member_activity CASCADE;
DROP VIEW IF EXISTS v_author_analytics CASCADE;
DROP VIEW IF EXISTS v_genre_analytics CASCADE;
DROP VIEW IF EXISTS v_popular_books_monthly CASCADE;
DROP VIEW IF EXISTS v_popular_books_weekly CASCADE;
DROP VIEW IF EXISTS v_copy_details CASCADE;
DROP VIEW IF EXISTS v_book_availability CASCADE;
DROP VIEW IF EXISTS v_overdue_items CASCADE;
DROP VIEW IF EXISTS v_popular_books CASCADE;
DROP VIEW IF EXISTS v_member_current_borrows CASCADE;

-- Drop all functions
DROP FUNCTION IF EXISTS search_books(TEXT, VARCHAR, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS return_book(BIGINT) CASCADE;
DROP FUNCTION IF EXISTS borrow_book(BIGINT, BIGINT, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_borrowing_statistics(DATE, DATE) CASCADE;
DROP FUNCTION IF EXISTS update_overdue_status() CASCADE;
DROP FUNCTION IF EXISTS check_borrowing_eligibility(BIGINT) CASCADE;
DROP FUNCTION IF EXISTS check_member_borrow_limit() CASCADE;
DROP FUNCTION IF EXISTS set_updated_at() CASCADE;

-- Drop all tables
DROP TABLE IF EXISTS borrowing_records CASCADE;
DROP TABLE IF EXISTS book_copies CASCADE;
DROP TABLE IF EXISTS book_authors CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS members CASCADE;

SELECT 'All tables dropped successfully!' AS status;
EOF

echo ""
echo "Running migrations..."
./scripts/run_local_migrations.sh

echo ""
echo "================================================"
echo "Database reset complete!"
echo "================================================"
