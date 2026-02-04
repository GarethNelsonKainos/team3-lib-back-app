# Database Layer Documentation

## Overview

The library system database is built on PostgreSQL and includes:
- 6 core tables for books, authors, members, and borrowing
- 13 analytical views for statistics and reporting
- 6 utility functions for business logic
- Comprehensive indexes for query performance
- Triggers for data integrity

## Quick Start

### Prerequisites
- PostgreSQL 15+ installed and running locally
- `psql` command-line tool available

### Running Migrations

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run all migrations (fresh database)
./scripts/run_local_migrations.sh

# Or reset and rebuild everything
./scripts/reset_database.sh
```

### Verify Installation

```bash
# Run health check
./scripts/health_check.sh

# Test functions
./scripts/test_functions.sh
```

## Database Schema

### Entity Relationship

```
authors ←──── book_authors ────→ books
                                   │
                                   ↓
members ←── borrowing_records ──→ book_copies
```

### Tables

| Table | Description |
|-------|-------------|
| `books` | Book catalog with title, ISBN, genre, etc. |
| `authors` | Author names |
| `book_authors` | Many-to-many junction table |
| `book_copies` | Physical copies of books |
| `members` | Library members |
| `borrowing_records` | Checkout/return transactions |

## Migration Files

Located in `src/database/migrations/`:

| File | Description |
|------|-------------|
| `001_initial_schema.sql` | Core tables and triggers |
| `002_indexes.sql` | Performance indexes |
| `003_borrowing_limit_trigger.sql` | Enforce 3-book limit |
| `004_core_views.sql` | Basic operational views |
| `005_analytics_views.sql` | Statistics and reporting views |
| `006_functions.sql` | Business logic functions |
| `007_seed_data.sql` | Sample development data |

## Key Functions

### `check_borrowing_eligibility(member_id)`
Check if a member can borrow books.

```sql
SELECT * FROM check_borrowing_eligibility(1);
-- Returns: is_eligible, current_borrows, max_borrows, has_overdue, reason
```

### `borrow_book(member_id, copy_id, loan_days)`
Process a book checkout.

```sql
SELECT * FROM borrow_book(1, 5, 14);
-- Returns: success, borrowing_id, due_date, message
```

### `return_book(copy_id)`
Process a book return.

```sql
SELECT * FROM return_book(5);
-- Returns: success, borrowing_id, was_overdue, days_overdue, message
```

### `update_overdue_status()`
Mark past-due borrows as OVERDUE.

```sql
SELECT * FROM update_overdue_status();
-- Returns: records_updated, execution_time
```

### `get_borrowing_statistics(start_date, end_date)`
Get borrowing statistics for a period.

```sql
SELECT * FROM get_borrowing_statistics('2025-01-01', '2025-01-31');
```

### `search_books(query, genre, limit)`
Search books by title, ISBN, or author.

```sql
SELECT * FROM search_books('potter', 'Fantasy', 10);
```

## Views

### Operational Views

| View | Description |
|------|-------------|
| `v_member_current_borrows` | Current borrows per member |
| `v_book_availability` | Copy availability by book |
| `v_copy_details` | Status of each physical copy |
| `v_overdue_items` | All overdue borrows |
| `v_popular_books` | Books ranked by borrow count |

### Analytics Views

| View | Description |
|------|-------------|
| `v_popular_books_weekly` | Most borrowed (7 days) |
| `v_popular_books_monthly` | Most borrowed (30 days) |
| `v_genre_analytics` | Stats by genre |
| `v_author_analytics` | Stats by author |
| `v_member_activity` | Member engagement levels |
| `v_collection_utilization` | Book usage patterns |
| `v_borrowing_trends_daily` | Borrows by day of week |
| `v_borrowing_trends_monthly` | Monthly borrow totals |
| `v_dashboard_summary` | Quick stats for dashboard |

## Business Rules (Enforced by Database)

1. **Borrowing Limit**: Maximum 3 books per member (trigger)
2. **Overdue Block**: Cannot borrow with overdue items (trigger)
3. **Unique Copy**: Only one active borrow per copy (unique index)
4. **Valid Dates**: Due date must be ≥ borrowed date (check constraint)
5. **Status Values**: Only BORROWED, RETURNED, OVERDUE allowed (check constraint)

## Utility Scripts

| Script | Description |
|--------|-------------|
| `run_local_migrations.sh` | Run all migration files |
| `reset_database.sh` | Drop all and rebuild |
| `backup_database.sh` | Export to SQL file |
| `health_check.sh` | Validate structure and data |
| `test_functions.sh` | Test all functions |

## Environment Variables

Scripts use these defaults (override as needed):

```bash
export DB_HOST=127.0.0.1
export DB_PORT=5432
export DB_USER=$(whoami)
export DB_NAME=library_dev
```

## Sample Queries

### Find available copies of a book
```sql
SELECT bc.copy_number, bc.status
FROM book_copies bc
JOIN books b ON bc.book_id = b.id
WHERE b.title ILIKE '%gatsby%'
  AND bc.status = 'AVAILABLE';
```

### Get member's borrowing history
```sql
SELECT b.title, br.borrowed_date, br.due_date, br.returned_date, br.status
FROM borrowing_records br
JOIN book_copies bc ON br.book_copy_id = bc.id
JOIN books b ON bc.book_id = b.id
JOIN members m ON br.member_id = m.id
WHERE m.member_id = 'MEM001'
ORDER BY br.borrowed_date DESC;
```

### Dashboard quick stats
```sql
SELECT * FROM v_dashboard_summary;
```
