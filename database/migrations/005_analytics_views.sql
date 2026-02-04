-- Migration 005: Analytics Views
-- Views for statistics and reporting

-- ============================================
-- VIEW: Weekly Popular Books
-- Most borrowed books in the last 7 days
-- ============================================
CREATE OR REPLACE VIEW v_popular_books_weekly AS
SELECT 
    b.id AS book_id,
    b.title,
    b.isbn,
    b.genre,
    STRING_AGG(DISTINCT a.name, ', ') AS authors,
    COUNT(br.id) AS borrow_count,
    COUNT(DISTINCT br.member_id) AS unique_borrowers
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrowing_records br ON bc.id = br.book_copy_id 
    AND br.borrowed_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY b.id, b.title, b.isbn, b.genre
HAVING COUNT(br.id) > 0
ORDER BY borrow_count DESC;

-- ============================================
-- VIEW: Monthly Popular Books
-- Most borrowed books in the last 30 days
-- ============================================
CREATE OR REPLACE VIEW v_popular_books_monthly AS
SELECT 
    b.id AS book_id,
    b.title,
    b.isbn,
    b.genre,
    STRING_AGG(DISTINCT a.name, ', ') AS authors,
    COUNT(br.id) AS borrow_count,
    COUNT(DISTINCT br.member_id) AS unique_borrowers
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrowing_records br ON bc.id = br.book_copy_id 
    AND br.borrowed_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY b.id, b.title, b.isbn, b.genre
HAVING COUNT(br.id) > 0
ORDER BY borrow_count DESC;

-- ============================================
-- VIEW: Genre Analytics
-- Borrowing statistics by genre
-- ============================================
CREATE OR REPLACE VIEW v_genre_analytics AS
SELECT 
    COALESCE(b.genre, 'Uncategorized') AS genre,
    COUNT(DISTINCT b.id) AS total_books,
    COUNT(DISTINCT bc.id) AS total_copies,
    COUNT(br.id) AS total_borrows,
    COUNT(br.id) FILTER (WHERE br.borrowed_date >= CURRENT_DATE - INTERVAL '30 days') AS borrows_last_30_days,
    COUNT(br.id) FILTER (WHERE br.borrowed_date >= CURRENT_DATE - INTERVAL '7 days') AS borrows_last_7_days,
    ROUND(
        COUNT(br.id)::NUMERIC / NULLIF(COUNT(DISTINCT b.id), 0), 
        2
    ) AS avg_borrows_per_book
FROM books b
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrowing_records br ON bc.id = br.book_copy_id
GROUP BY b.genre
ORDER BY total_borrows DESC;

-- ============================================
-- VIEW: Author Analytics
-- Most borrowed authors
-- ============================================
CREATE OR REPLACE VIEW v_author_analytics AS
SELECT 
    a.id AS author_id,
    a.name AS author_name,
    COUNT(DISTINCT b.id) AS total_books,
    COUNT(DISTINCT bc.id) AS total_copies,
    COUNT(br.id) AS total_borrows,
    COUNT(br.id) FILTER (WHERE br.borrowed_date >= CURRENT_DATE - INTERVAL '30 days') AS borrows_last_30_days,
    ARRAY_AGG(DISTINCT b.title) AS book_titles
FROM authors a
JOIN book_authors ba ON a.id = ba.author_id
JOIN books b ON ba.book_id = b.id
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrowing_records br ON bc.id = br.book_copy_id
GROUP BY a.id, a.name
ORDER BY total_borrows DESC;

-- ============================================
-- VIEW: Member Activity
-- Member engagement and borrowing patterns
-- ============================================
CREATE OR REPLACE VIEW v_member_activity AS
SELECT 
    m.id AS member_id,
    m.member_id AS member_code,
    m.first_name || ' ' || m.last_name AS member_name,
    m.membership_date,
    COUNT(br.id) AS total_borrows,
    COUNT(br.id) FILTER (WHERE br.borrowed_date >= CURRENT_DATE - INTERVAL '30 days') AS borrows_last_30_days,
    COUNT(br.id) FILTER (WHERE br.returned_date IS NULL) AS current_borrows,
    COUNT(br.id) FILTER (WHERE br.status = 'OVERDUE' OR (br.returned_date IS NULL AND br.due_date < CURRENT_DATE)) AS overdue_count,
    MAX(br.borrowed_date) AS last_borrow_date,
    CASE 
        WHEN MAX(br.borrowed_date) >= CURRENT_DATE - INTERVAL '30 days' THEN 'Active'
        WHEN MAX(br.borrowed_date) >= CURRENT_DATE - INTERVAL '90 days' THEN 'Moderate'
        WHEN MAX(br.borrowed_date) IS NOT NULL THEN 'Inactive'
        ELSE 'Never Borrowed'
    END AS activity_status
FROM members m
LEFT JOIN borrowing_records br ON m.id = br.member_id
GROUP BY m.id, m.member_id, m.first_name, m.last_name, m.membership_date
ORDER BY total_borrows DESC;

-- ============================================
-- VIEW: Collection Utilization
-- Books that are never/rarely borrowed vs high demand
-- ============================================
CREATE OR REPLACE VIEW v_collection_utilization AS
SELECT 
    b.id AS book_id,
    b.title,
    b.isbn,
    b.genre,
    COUNT(DISTINCT bc.id) AS total_copies,
    COUNT(br.id) AS total_borrows,
    COUNT(br.id) FILTER (WHERE br.borrowed_date >= CURRENT_DATE - INTERVAL '90 days') AS borrows_last_90_days,
    COUNT(DISTINCT bc.id) FILTER (WHERE bc.status = 'AVAILABLE') AS available_now,
    CASE 
        WHEN COUNT(br.id) = 0 THEN 'Never Borrowed'
        WHEN COUNT(br.id) FILTER (WHERE br.borrowed_date >= CURRENT_DATE - INTERVAL '90 days') = 0 THEN 'Not Recently Used'
        WHEN COUNT(br.id) FILTER (WHERE br.borrowed_date >= CURRENT_DATE - INTERVAL '30 days') >= COUNT(DISTINCT bc.id) THEN 'High Demand'
        ELSE 'Normal'
    END AS utilization_category,
    ROUND(
        COUNT(br.id)::NUMERIC / GREATEST(COUNT(DISTINCT bc.id), 1), 
        2
    ) AS borrows_per_copy
FROM books b
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrowing_records br ON bc.id = br.book_copy_id
GROUP BY b.id, b.title, b.isbn, b.genre
ORDER BY utilization_category, total_borrows DESC;

-- ============================================
-- VIEW: Daily Borrowing Trends
-- Borrowing activity by day of week
-- ============================================
CREATE OR REPLACE VIEW v_borrowing_trends_daily AS
SELECT 
    TO_CHAR(borrowed_date, 'Day') AS day_of_week,
    EXTRACT(DOW FROM borrowed_date) AS day_number,
    COUNT(*) AS total_borrows,
    COUNT(*) FILTER (WHERE borrowed_date >= CURRENT_DATE - INTERVAL '30 days') AS borrows_last_30_days
FROM borrowing_records
GROUP BY TO_CHAR(borrowed_date, 'Day'), EXTRACT(DOW FROM borrowed_date)
ORDER BY day_number;

-- ============================================
-- VIEW: Monthly Borrowing Trends
-- Borrowing activity by month
-- ============================================
CREATE OR REPLACE VIEW v_borrowing_trends_monthly AS
SELECT 
    TO_CHAR(borrowed_date, 'YYYY-MM') AS month,
    COUNT(*) AS total_borrows,
    COUNT(DISTINCT member_id) AS unique_members,
    COUNT(DISTINCT book_copy_id) AS unique_copies_borrowed
FROM borrowing_records
GROUP BY TO_CHAR(borrowed_date, 'YYYY-MM')
ORDER BY month DESC;

-- ============================================
-- VIEW: Library Dashboard Summary
-- Quick stats for dashboard
-- ============================================
CREATE OR REPLACE VIEW v_dashboard_summary AS
SELECT 
    (SELECT COUNT(*) FROM books) AS total_books,
    (SELECT COUNT(*) FROM book_copies) AS total_copies,
    (SELECT COUNT(*) FROM book_copies WHERE status = 'AVAILABLE') AS available_copies,
    (SELECT COUNT(*) FROM book_copies WHERE status = 'BORROWED') AS borrowed_copies,
    (SELECT COUNT(*) FROM members) AS total_members,
    (SELECT COUNT(DISTINCT member_id) FROM borrowing_records WHERE borrowed_date >= CURRENT_DATE - INTERVAL '30 days') AS active_members_30d,
    (SELECT COUNT(*) FROM borrowing_records WHERE returned_date IS NULL) AS active_borrows,
    (SELECT COUNT(*) FROM borrowing_records WHERE returned_date IS NULL AND due_date < CURRENT_DATE) AS overdue_items,
    (SELECT COUNT(*) FROM borrowing_records WHERE borrowed_date = CURRENT_DATE) AS borrows_today,
    (SELECT COUNT(*) FROM borrowing_records WHERE returned_date = CURRENT_DATE) AS returns_today;
