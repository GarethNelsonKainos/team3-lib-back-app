-- ============================================
-- Database Schema: Library Management System (Version 2)
-- Generated: February 4, 2026
-- PostgreSQL Version: 14+
-- Description: Comprehensive library book borrowing system
-- ============================================

-- No extensions, domains, or custom types in simplified version

-- ============================================
-- Table: genres
-- Description: Book genre categories (reference table)
-- ============================================
CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Insert common genres
INSERT INTO genres (name) VALUES
    ('Fiction'), ('Non-Fiction'), ('Science Fiction'), ('Mystery'),
    ('Biography'), ('History'), ('Science'), ('Technology'),
    ('Fantasy'), ('Romance'), ('Thriller'), ('Children');

-- ============================================
-- Table: authors
-- Description: Author information
-- ============================================
CREATE TABLE authors (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL
);

-- ============================================
-- Table: books
-- Description: Book catalog with metadata
-- ============================================
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    isbn VARCHAR(17) NOT NULL UNIQUE CHECK (isbn ~ '^(97[89])?\d{9}[\dX]$'),
    title VARCHAR(500) NOT NULL,
    genre_id INTEGER REFERENCES genres(id) ON DELETE RESTRICT,
    publication_year INTEGER,
    publisher VARCHAR(255),
    description TEXT,
    total_copies INTEGER DEFAULT 0 NOT NULL,
    available_copies INTEGER DEFAULT 0 NOT NULL,
    CONSTRAINT books_copies_valid CHECK (available_copies >= 0 AND available_copies <= total_copies)
);

-- ============================================
-- Table: book_authors
-- Description: Junction table for books and authors (many-to-many)
-- ============================================
CREATE TABLE book_authors (
    book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    author_id INTEGER NOT NULL REFERENCES authors(id) ON DELETE RESTRICT,
    author_order INTEGER DEFAULT 1 NOT NULL,
    PRIMARY KEY (book_id, author_id)
);

-- ============================================
-- Table: book_copies
-- Description: Individual physical copies of books
-- ============================================
CREATE TABLE book_copies (
    id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
    copy_number VARCHAR(50) NOT NULL UNIQUE,
    barcode VARCHAR(100) UNIQUE,
    status VARCHAR(20) DEFAULT 'available' NOT NULL CHECK (status IN ('available', 'borrowed', 'maintenance', 'lost')),
    acquisition_date DATE DEFAULT CURRENT_DATE NOT NULL,
    location VARCHAR(100),
    total_borrows INTEGER DEFAULT 0 NOT NULL
);

-- ============================================
-- Table: members
-- Description: Library members and their information
-- ============================================
CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
    phone VARCHAR(20) CHECK (phone ~ '^\+?[1-9]\d{1,14}$'),
    address VARCHAR(500),
    status VARCHAR(20) DEFAULT 'active' NOT NULL CHECK (status IN ('active', 'suspended', 'expired')),
    membership_start_date DATE DEFAULT CURRENT_DATE NOT NULL,
    max_books_allowed INTEGER DEFAULT 3 NOT NULL,
    current_books_borrowed INTEGER DEFAULT 0 NOT NULL,
    total_books_borrowed INTEGER DEFAULT 0 NOT NULL,
    has_overdue_books BOOLEAN DEFAULT false NOT NULL,
    CONSTRAINT members_current_books_valid CHECK (current_books_borrowed >= 0 AND current_books_borrowed <= max_books_allowed)
);

-- ============================================
-- Table: borrowing_transactions
-- Description: Complete borrowing and return history
-- ============================================
CREATE TABLE borrowing_transactions (
    id SERIAL PRIMARY KEY,
    member_id INTEGER NOT NULL REFERENCES members(id) ON DELETE RESTRICT,
    book_copy_id INTEGER NOT NULL REFERENCES book_copies(id) ON DELETE RESTRICT,
    book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
    status VARCHAR(20) DEFAULT 'active' NOT NULL CHECK (status IN ('active', 'returned')),
    borrowed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    due_date DATE NOT NULL,
    returned_at TIMESTAMP,
    days_overdue INTEGER DEFAULT 0 NOT NULL,
    CONSTRAINT borrowing_dates_valid CHECK (returned_at IS NULL OR returned_at >= borrowed_at)
);

-- ============================================
-- Functions & Triggers
-- ============================================

-- Function: Update book copy counts when copies are added/removed
CREATE OR REPLACE FUNCTION update_book_copy_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        UPDATE books SET
            total_copies = (
                SELECT COUNT(*) FROM book_copies 
                WHERE book_id = NEW.book_id
            ),
            available_copies = (
                SELECT COUNT(*) FROM book_copies 
                WHERE book_id = NEW.book_id AND status = 'available'
            )
        WHERE id = NEW.book_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE books SET
            total_copies = (
                SELECT COUNT(*) FROM book_copies 
                WHERE book_id = OLD.book_id
            ),
            available_copies = (
                SELECT COUNT(*) FROM book_copies 
                WHERE book_id = OLD.book_id AND status = 'available'
            )
        WHERE id = OLD.book_id;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER book_copies_update_counts
    AFTER INSERT OR UPDATE OR DELETE ON book_copies
    FOR EACH ROW
    EXECUTE FUNCTION update_book_copy_counts();

-- Function: Update member borrowing counts
CREATE OR REPLACE FUNCTION update_member_borrow_counts()
RETURNS TRIGGER AS $$
DECLARE
    v_member_id INTEGER;
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        v_member_id := NEW.member_id;
    ELSE
        v_member_id := OLD.member_id;
    END IF;

    UPDATE members SET
        current_books_borrowed = (
            SELECT COUNT(*) FROM borrowing_transactions
            WHERE member_id = v_member_id AND status = 'active'
        ),
        has_overdue_books = (
            SELECT EXISTS(
                SELECT 1 FROM borrowing_transactions
                WHERE member_id = v_member_id AND status = 'active' 
                AND CURRENT_DATE > due_date
            )
        )
    WHERE id = v_member_id;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER borrowing_update_member_counts
    AFTER INSERT OR UPDATE OR DELETE ON borrowing_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_member_borrow_counts();

-- Function: Validate borrowing eligibility
CREATE OR REPLACE FUNCTION check_borrowing_eligibility()
RETURNS TRIGGER AS $$
DECLARE
    v_member_status VARCHAR;
    v_current_books INTEGER;
    v_max_books INTEGER;
    v_has_overdue BOOLEAN;
    v_copy_status VARCHAR;
BEGIN
    -- Get member information
    SELECT status, current_books_borrowed, max_books_allowed, has_overdue_books
    INTO v_member_status, v_current_books, v_max_books, v_has_overdue
    FROM members
    WHERE id = NEW.member_id;

    -- Check if member exists and is active
    IF v_member_status IS NULL THEN
        RAISE EXCEPTION 'Member does not exist';
    END IF;

    IF v_member_status != 'active' THEN
        RAISE EXCEPTION 'Member status is %. Only active members can borrow books.', v_member_status;
    END IF;

    -- Check if member has overdue books
    IF v_has_overdue THEN
        RAISE EXCEPTION 'Member has overdue books. Returns must be completed before new borrowing.';
    END IF;

    -- Check borrowing limit
    IF v_current_books >= v_max_books THEN
        RAISE EXCEPTION 'Member has reached maximum borrowing limit of % books', v_max_books;
    END IF;

    -- Check if copy is available
    SELECT status INTO v_copy_status
    FROM book_copies
    WHERE id = NEW.book_copy_id;

    IF v_copy_status != 'available' THEN
        RAISE EXCEPTION 'Book copy is not available. Current status: %', v_copy_status;
    END IF;

    -- Set due date if not provided (14 days default)
    IF NEW.due_date IS NULL THEN
        NEW.due_date := CURRENT_DATE + INTERVAL '14 days';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER borrowing_check_eligibility
    BEFORE INSERT ON borrowing_transactions
    FOR EACH ROW
    EXECUTE FUNCTION check_borrowing_eligibility();

-- Function: Update copy status when borrowed/returned
CREATE OR REPLACE FUNCTION update_copy_status_on_borrow()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' AND NEW.status = 'active') THEN
        -- Mark copy as borrowed
        UPDATE book_copies SET
            status = 'borrowed',
            last_borrowed_at = NEW.borrowed_at,
            total_borrows = total_borrows + 1
        WHERE id = NEW.book_copy_id;
        
    ELSIF (TG_OP = 'UPDATE' AND OLD.status = 'active' AND NEW.status = 'returned') THEN
        -- Mark copy as available on return
        UPDATE book_copies SET
            status = 'available'
        WHERE id = NEW.book_copy_id;
        
        -- Calculate overdue days
        IF NEW.returned_at::date > NEW.due_date THEN
            NEW.days_overdue := NEW.returned_at::date - NEW.due_date;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER borrowing_update_copy_status
    BEFORE INSERT OR UPDATE ON borrowing_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_copy_status_on_borrow();

-- Function: Increment total books borrowed for member
CREATE OR REPLACE FUNCTION increment_member_total_borrows()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE members SET
        total_books_borrowed = total_books_borrowed + 1
    WHERE id = NEW.member_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER borrowing_increment_member_total
    AFTER INSERT ON borrowing_transactions
    FOR EACH ROW
    EXECUTE FUNCTION increment_member_total_borrows();

-- ============================================
-- Useful Views
-- ============================================

-- View: Current overdue books
CREATE VIEW overdue_books AS
SELECT 
    bt.id AS transaction_id,
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.email,
    m.phone,
    b.title AS book_title,
    b.isbn,
    bc.copy_number,
    bt.borrowed_at,
    bt.due_date,
    CURRENT_DATE - bt.due_date AS days_overdue
FROM borrowing_transactions bt
JOIN members m ON bt.member_id = m.id
JOIN books b ON bt.book_id = b.id
JOIN book_copies bc ON bt.book_copy_id = bc.id
WHERE bt.status = 'active' AND bt.due_date < CURRENT_DATE
ORDER BY bt.due_date ASC;

-- View: Available books with author info
CREATE VIEW books_available AS
SELECT 
    b.id,
    b.isbn,
    b.title,
    g.name AS genre,
    b.publication_year,
    b.total_copies,
    b.available_copies,
    STRING_AGG(a.first_name || ' ' || a.last_name, ', ' ORDER BY ba.author_order) AS authors
FROM books b
LEFT JOIN genres g ON b.genre_id = g.id
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
GROUP BY b.id, b.isbn, b.title, g.name, b.publication_year, b.total_copies, b.available_copies;

-- View: Member borrowing status
CREATE VIEW member_status AS
SELECT 
    m.id,
    m.member_id,
    m.first_name || ' ' || m.last_name AS full_name,
    m.email,
    m.status,
    m.current_books_borrowed,
    m.max_books_allowed,
    m.max_books_allowed - m.current_books_borrowed AS available_slots,
    m.total_books_borrowed,
    m.has_overdue_books
FROM members m;

-- ============================================
-- Helper Functions for Reporting
-- ============================================

-- Function: Get top books for a specific time period
CREATE OR REPLACE FUNCTION get_top_books(
    p_period VARCHAR DEFAULT 'month',
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    book_id INTEGER,
    title VARCHAR,
    authors TEXT,
    genre VARCHAR,
    borrow_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        b.title,
        STRING_AGG(a.first_name || ' ' || a.last_name, ', ' ORDER BY ba.author_order) AS authors,
        g.name AS genre,
        COUNT(bt.id) AS borrow_count
    FROM books b
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    LEFT JOIN genres g ON b.genre_id = g.id
    LEFT JOIN borrowing_transactions bt ON b.id = bt.book_id
        AND CASE 
            WHEN p_period = 'week' THEN bt.borrowed_at >= CURRENT_DATE - INTERVAL '7 days'
            WHEN p_period = 'month' THEN bt.borrowed_at >= CURRENT_DATE - INTERVAL '30 days'
            WHEN p_period = 'year' THEN bt.borrowed_at >= CURRENT_DATE - INTERVAL '1 year'
            ELSE TRUE
        END
    GROUP BY b.id, b.title, g.name
    ORDER BY borrow_count DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Function: Get member borrowing history
CREATE OR REPLACE FUNCTION get_member_history(p_member_id INTEGER)
RETURNS TABLE (
    transaction_id INTEGER,
    book_title VARCHAR,
    authors TEXT,
    copy_number VARCHAR,
    borrowed_at TIMESTAMP,
    due_date DATE,
    returned_at TIMESTAMP,
    days_overdue INTEGER,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bt.id,
        b.title,
        STRING_AGG(a.first_name || ' ' || a.last_name, ', ' ORDER BY ba.author_order),
        bc.copy_number,
        bt.borrowed_at,
        bt.due_date,
        bt.returned_at,
        bt.days_overdue,
        bt.status
    FROM borrowing_transactions bt
    JOIN books b ON bt.book_id = b.id
    JOIN book_copies bc ON bt.book_copy_id = bc.id
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    WHERE bt.member_id = p_member_id
    GROUP BY bt.id, b.title, bc.copy_number, bt.borrowed_at, bt.due_date, 
             bt.returned_at, bt.days_overdue, bt.status
    ORDER BY bt.borrowed_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Database Roles & Permissions
-- ============================================

-- Create application roles
CREATE ROLE library_readonly;
CREATE ROLE library_librarian;
CREATE ROLE library_admin;

-- Grant permissions for read-only role
GRANT SELECT ON ALL TABLES IN SCHEMA public TO library_readonly;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO library_readonly;

-- Grant permissions for librarian role (normal operations)
GRANT SELECT, INSERT, UPDATE ON books, book_copies, authors, book_authors, 
      members, borrowing_transactions TO library_librarian;
GRANT SELECT ON genres TO library_librarian;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO library_librarian;

-- Grant all permissions to admin
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO library_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO library_admin;

-- ============================================
-- Initial Data / Seed
-- ============================================

-- Success message
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Library Management System (Simplified)';
    RAISE NOTICE 'Successfully created!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Tables: 7';
    RAISE NOTICE 'Views: 3';
    RAISE NOTICE 'Functions: 5';
    RAISE NOTICE 'Triggers: 5';
    RAISE NOTICE 'Max Scale: 100,000 members';
    RAISE NOTICE '========================================';
END $$;
