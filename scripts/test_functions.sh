#!/bin/bash
# Quick test of database functions
# Usage: ./scripts/test_functions.sh

set -e

# Configuration
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-$(whoami)}"
DB_NAME="${DB_NAME:-library_dev}"

echo "================================================"
echo "Library System - Function Tests"
echo "================================================"
echo ""

psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" << 'EOF'

\echo '--- Test 1: Check Borrowing Eligibility ---'
-- Test with first member
SELECT * FROM check_borrowing_eligibility(
    (SELECT id FROM members WHERE member_id = 'MEM001')
);

\echo ''
\echo '--- Test 2: Update Overdue Status ---'
SELECT * FROM update_overdue_status();

\echo ''
\echo '--- Test 3: Get Borrowing Statistics (Last 30 days) ---'
SELECT * FROM get_borrowing_statistics();

\echo ''
\echo '--- Test 4: Search Books ---'
SELECT * FROM search_books('the', NULL, 5);

\echo ''
\echo '--- Test 5: Search Books by Genre ---'
SELECT * FROM search_books(NULL, 'Fantasy', 5);

\echo ''
\echo '--- Test 6: View - Dashboard Summary ---'
SELECT * FROM v_dashboard_summary;

\echo ''
\echo '--- Test 7: View - Book Availability ---'
SELECT * FROM v_book_availability LIMIT 5;

\echo ''
\echo '--- Test 8: View - Member Activity ---'
SELECT member_code, member_name, total_borrows, current_borrows, activity_status 
FROM v_member_activity LIMIT 5;

\echo ''
\echo '--- Test 9: View - Genre Analytics ---'
SELECT * FROM v_genre_analytics;

\echo ''
\echo '--- Test 10: View - Overdue Items ---'
SELECT * FROM v_overdue_items;

\echo ''
\echo '--- All Tests Completed ---'
EOF

echo ""
echo "================================================"
echo "Function tests completed!"
echo "================================================"
