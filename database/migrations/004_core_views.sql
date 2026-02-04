-- Migration 004: Core Views
-- Basic views for common queries

-- ============================================
-- VIEW: Member Current Borrows
-- Shows current borrowing status for each member
-- ============================================
CREATE OR REPLACE VIEW v_member_current_borrows AS
SELECT 
    m.id AS member_id,
    m.member_id AS member_code,
    m.first_name,
    m.last_name,
    m.email,
    COUNT(br.id) AS current_borrow_count,
    3 - COUNT(br.id) AS remaining_slots,
    BOOL_OR(br.due_date < CURRENT_DATE) AS has_overdue,
    ARRAY_AGG(
        DISTINCT jsonb_build_object(
            'book_title', b.title,
            'copy_number', bc.copy_number,
            'borrowed_date', br.borrowed_date,
            'due_date', br.due_date,
            'is_overdue', br.due_date < CURRENT_DATE
        )
    ) FILTER (WHERE br.id IS NOT NULL) AS borrowed_books
FROM members m
LEFT JOIN borrowing_records br ON m.id = br.member_id AND br.returned_date IS NULL
LEFT JOIN book_copies bc ON br.book_copy_id = bc.id
LEFT JOIN books b ON bc.book_id = b.id
GROUP BY m.id, m.member_id, m.first_name, m.last_name, m.email;

-- ============================================
-- VIEW: Popular Books
-- Books ranked by total borrow count
-- ============================================
CREATE OR REPLACE VIEW v_popular_books AS
SELECT 
    b.id AS book_id,
    b.title,
    b.isbn,
    b.genre,
    STRING_AGG(DISTINCT a.name, ', ') AS authors,
    COUNT(br.id) AS borrow_count,
    COUNT(DISTINCT br.member_id) AS unique_borrowers,
    MAX(br.borrowed_date) AS last_borrowed
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrowing_records br ON bc.id = br.book_copy_id
GROUP BY b.id, b.title, b.isbn, b.genre
ORDER BY borrow_count DESC;

-- ============================================
-- VIEW: Overdue Items
-- All currently overdue borrows with member and book details
-- ============================================
CREATE OR REPLACE VIEW v_overdue_items AS
SELECT 
    br.id AS borrowing_id,
    m.id AS member_pk,
    m.member_id AS member_code,
    m.first_name || ' ' || m.last_name AS member_name,
    m.email,
    m.phone,
    b.id AS book_id,
    b.title AS book_title,
    bc.copy_number,
    br.borrowed_date,
    br.due_date,
    CURRENT_DATE - br.due_date AS days_overdue,
    br.status
FROM borrowing_records br
JOIN members m ON br.member_id = m.id
JOIN book_copies bc ON br.book_copy_id = bc.id
JOIN books b ON bc.book_id = b.id
WHERE br.returned_date IS NULL
  AND br.due_date < CURRENT_DATE
ORDER BY days_overdue DESC;

-- ============================================
-- VIEW: Book Availability
-- Summary of each book's copy availability
-- ============================================
CREATE OR REPLACE VIEW v_book_availability AS
SELECT 
    b.id AS book_id,
    b.title,
    b.isbn,
    b.genre,
    STRING_AGG(DISTINCT a.name, ', ') AS authors,
    COUNT(bc.id) AS total_copies,
    COUNT(bc.id) FILTER (WHERE bc.status = 'AVAILABLE') AS available_copies,
    COUNT(bc.id) FILTER (WHERE bc.status = 'BORROWED') AS borrowed_copies
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
LEFT JOIN book_copies bc ON b.id = bc.book_id
GROUP BY b.id, b.title, b.isbn, b.genre
ORDER BY b.title;

-- ============================================
-- VIEW: Copy Details
-- Detailed status of each book copy
-- ============================================
CREATE OR REPLACE VIEW v_copy_details AS
SELECT 
    bc.id AS copy_id,
    bc.copy_number,
    b.id AS book_id,
    b.title,
    b.isbn,
    bc.status,
    CASE 
        WHEN bc.status = 'BORROWED' THEN m.first_name || ' ' || m.last_name
        ELSE NULL
    END AS borrowed_by,
    CASE 
        WHEN bc.status = 'BORROWED' THEN br.due_date
        ELSE NULL
    END AS due_date,
    CASE 
        WHEN bc.status = 'BORROWED' AND br.due_date < CURRENT_DATE THEN TRUE
        ELSE FALSE
    END AS is_overdue
FROM book_copies bc
JOIN books b ON bc.book_id = b.id
LEFT JOIN borrowing_records br ON bc.id = br.book_copy_id AND br.returned_date IS NULL
LEFT JOIN members m ON br.member_id = m.id
ORDER BY b.title, bc.copy_number;
