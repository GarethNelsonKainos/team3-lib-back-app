#!/bin/bash
# Health check script - validates database structure and data integrity
# Usage: ./scripts/health_check.sh

set -e

# Configuration
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-$(whoami)}"
DB_NAME="${DB_NAME:-library_dev}"

echo "================================================"
echo "Library System - Database Health Check"
echo "================================================"
echo "Database: $DB_NAME @ $DB_HOST:$DB_PORT"
echo "Time: $(date)"
echo "================================================"
echo ""

# Run health check queries
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" << 'EOF'

-- Check 1: Table existence and row counts
\echo '--- Table Statistics ---'
SELECT 
    schemaname,
    relname AS table_name,
    n_live_tup AS row_count
FROM pg_stat_user_tables
ORDER BY relname;

-- Check 2: Index usage
\echo ''
\echo '--- Index Usage Statistics ---'
SELECT 
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan AS times_used,
    idx_tup_read AS tuples_read
FROM pg_stat_user_indexes
WHERE idx_scan > 0
ORDER BY idx_scan DESC
LIMIT 10;

-- Check 3: Data integrity - orphaned records
\echo ''
\echo '--- Data Integrity Checks ---'

SELECT 'Book copies without books' AS check_name,
    COUNT(*) AS issues
FROM book_copies bc
WHERE NOT EXISTS (SELECT 1 FROM books b WHERE b.id = bc.book_id)

UNION ALL

SELECT 'Borrowing records without members',
    COUNT(*)
FROM borrowing_records br
WHERE NOT EXISTS (SELECT 1 FROM members m WHERE m.id = br.member_id)

UNION ALL

SELECT 'Borrowing records without book copies',
    COUNT(*)
FROM borrowing_records br
WHERE NOT EXISTS (SELECT 1 FROM book_copies bc WHERE bc.id = br.book_copy_id)

UNION ALL

SELECT 'Book-author links without books',
    COUNT(*)
FROM book_authors ba
WHERE NOT EXISTS (SELECT 1 FROM books b WHERE b.id = ba.book_id)

UNION ALL

SELECT 'Book-author links without authors',
    COUNT(*)
FROM book_authors ba
WHERE NOT EXISTS (SELECT 1 FROM authors a WHERE a.id = ba.author_id);

-- Check 4: Copy status consistency
\echo ''
\echo '--- Copy Status Consistency ---'
SELECT 
    'Copies marked BORROWED but no active borrow' AS issue,
    COUNT(*) AS count
FROM book_copies bc
WHERE bc.status = 'BORROWED'
  AND NOT EXISTS (
      SELECT 1 FROM borrowing_records br 
      WHERE br.book_copy_id = bc.id AND br.returned_date IS NULL
  )

UNION ALL

SELECT 
    'Copies marked AVAILABLE but have active borrow',
    COUNT(*)
FROM book_copies bc
WHERE bc.status = 'AVAILABLE'
  AND EXISTS (
      SELECT 1 FROM borrowing_records br 
      WHERE br.book_copy_id = bc.id AND br.returned_date IS NULL
  );

-- Check 5: Overdue status consistency
\echo ''
\echo '--- Overdue Status Check ---'
SELECT 
    'Records past due but not marked OVERDUE' AS issue,
    COUNT(*) AS count
FROM borrowing_records
WHERE returned_date IS NULL
  AND due_date < CURRENT_DATE
  AND status != 'OVERDUE';

-- Check 6: Database summary
\echo ''
\echo '--- Database Summary ---'
SELECT * FROM v_dashboard_summary;

-- Check 7: Function availability
\echo ''
\echo '--- Functions Available ---'
SELECT 
    proname AS function_name,
    pg_get_function_arguments(oid) AS arguments
FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
  AND proname IN (
      'check_borrowing_eligibility', 
      'update_overdue_status', 
      'get_borrowing_statistics',
      'borrow_book',
      'return_book',
      'search_books'
  );

-- Check 8: Views available
\echo ''
\echo '--- Views Available ---'
SELECT viewname 
FROM pg_views 
WHERE schemaname = 'public'
ORDER BY viewname;

\echo ''
\echo '--- Health Check Complete ---'
EOF

echo ""
echo "================================================"
echo "Health check completed!"
echo "================================================"
