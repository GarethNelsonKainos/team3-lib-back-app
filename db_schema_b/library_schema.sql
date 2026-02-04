-- ============================================
-- Database Schema: Library Management System
-- Generated: February 4, 2026
-- PostgreSQL Version: 14+
-- Description: Comprehensive library book borrowing system
-- ============================================

-- ============================================
-- Extensions
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";              -- Full-text search

-- ============================================
-- Custom Domains
-- ============================================
CREATE DOMAIN email_address AS VARCHAR(255)
    CHECK (VALUE ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

CREATE DOMAIN phone_number AS VARCHAR(20)
    CHECK (VALUE ~ '^\+?[1-9]\d{1,14}$');

CREATE DOMAIN isbn_code AS VARCHAR(17)
    CHECK (VALUE ~ '^(97[89])?\d{9}[\dX]$');

-- ============================================
-- Custom Types (ENUMS)
-- ============================================
CREATE TYPE copy_status AS ENUM ('available', 'borrowed', 'maintenance', 'lost');
CREATE TYPE member_status AS ENUM ('active', 'suspended', 'expired', 'deleted');
CREATE TYPE transaction_status AS ENUM ('active', 'returned', 'overdue');

-- ============================================
-- Table: genres
-- Description: Book genre categories (reference table)
-- ============================================
CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX idx_genres_name ON genres(name);

COMMENT ON TABLE genres IS 'Reference table for book genre categories';

-- Insert common genres
INSERT INTO genres (name, description) VALUES
    ('Fiction', 'Literary fiction and novels'),
    ('Non-Fiction', 'Factual and informative works'),
    ('Science Fiction', 'Speculative and futuristic stories'),
    ('Mystery', 'Detective and crime fiction'),
    ('Biography', 'Life stories and memoirs'),
    ('History', 'Historical accounts and studies'),
    ('Science', 'Scientific texts and research'),
    ('Technology', 'Technology and computing'),
    ('Fantasy', 'Fantasy and magical realism'),
    ('Romance', 'Romantic fiction'),
    ('Thriller', 'Suspense and thriller novels'),
    ('Children', 'Children''s books and young adult');

-- ============================================
-- Table: authors
-- Description: Author information
-- ============================================
CREATE TABLE authors (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(201) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    biography TEXT,
    birth_year INTEGER,
    nationality VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT authors_birth_year_check CHECK (birth_year >= 1000 AND birth_year <= EXTRACT(YEAR FROM CURRENT_DATE))
);

-- Indexes
CREATE INDEX idx_authors_full_name ON authors(full_name) WHERE deleted_at IS NULL;
CREATE INDEX idx_authors_last_name ON authors(last_name) WHERE deleted_at IS NULL;
CREATE INDEX idx_authors_full_name_trgm ON authors USING GIN(full_name gin_trgm_ops);

COMMENT ON TABLE authors IS 'Author information and metadata';
COMMENT ON COLUMN authors.uuid IS 'Public-facing unique identifier for API use';

-- ============================================
-- Table: books
-- Description: Book catalog with metadata
-- ============================================
CREATE TABLE books (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
    isbn isbn_code NOT NULL UNIQUE,
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    genre_id INTEGER REFERENCES genres(id) ON DELETE RESTRICT,
    publication_year INTEGER,
    publisher VARCHAR(255),
    edition VARCHAR(100),
    language VARCHAR(50) DEFAULT 'English' NOT NULL,
    pages INTEGER,
    description TEXT,
    cover_image_url TEXT,
    total_copies INTEGER DEFAULT 0 NOT NULL,
    available_copies INTEGER DEFAULT 0 NOT NULL,
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(subtitle, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(description, '')), 'C')
    ) STORED,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT books_publication_year_check CHECK (publication_year >= 1000 AND publication_year <= EXTRACT(YEAR FROM CURRENT_DATE) + 1),
    CONSTRAINT books_pages_positive CHECK (pages > 0),
    CONSTRAINT books_copies_valid CHECK (available_copies >= 0 AND available_copies <= total_copies)
);

-- Indexes
CREATE INDEX idx_books_isbn ON books(isbn) WHERE deleted_at IS NULL;
CREATE INDEX idx_books_title ON books(title) WHERE deleted_at IS NULL;
CREATE INDEX idx_books_genre_id ON books(genre_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_books_publication_year ON books(publication_year) WHERE deleted_at IS NULL;
CREATE INDEX idx_books_search_vector ON books USING GIN(search_vector);
CREATE INDEX idx_books_available_copies ON books(available_copies) WHERE deleted_at IS NULL AND available_copies > 0;

COMMENT ON TABLE books IS 'Book catalog with metadata and copy tracking';
COMMENT ON COLUMN books.search_vector IS 'Full-text search vector for title, subtitle, and description';
COMMENT ON COLUMN books.total_copies IS 'Total number of physical copies';
COMMENT ON COLUMN books.available_copies IS 'Number of copies currently available for borrowing';

-- ============================================
-- Table: book_authors
-- Description: Junction table for books and authors (many-to-many)
-- ============================================
CREATE TABLE book_authors (
    id BIGSERIAL PRIMARY KEY,
    book_id BIGINT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    author_id BIGINT NOT NULL REFERENCES authors(id) ON DELETE RESTRICT,
    author_order INTEGER DEFAULT 1 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE(book_id, author_id),
    CONSTRAINT book_authors_order_positive CHECK (author_order > 0)
);

CREATE INDEX idx_book_authors_book_id ON book_authors(book_id);
CREATE INDEX idx_book_authors_author_id ON book_authors(author_id);

COMMENT ON TABLE book_authors IS 'Many-to-many relationship between books and authors';
COMMENT ON COLUMN book_authors.author_order IS 'Order of authors for display (1 = primary author)';

-- ============================================
-- Table: book_copies
-- Description: Individual physical copies of books
-- ============================================
CREATE TABLE book_copies (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
    book_id BIGINT NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
    copy_number VARCHAR(50) NOT NULL UNIQUE,
    barcode VARCHAR(100) UNIQUE,
    status copy_status DEFAULT 'available' NOT NULL,
    condition_notes TEXT,
    acquisition_date DATE DEFAULT CURRENT_DATE NOT NULL,
    purchase_price DECIMAL(10, 2),
    location VARCHAR(100),
    last_borrowed_at TIMESTAMPTZ,
    total_borrows INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT book_copies_purchase_price_positive CHECK (purchase_price >= 0)
);

-- Indexes
CREATE INDEX idx_book_copies_book_id ON book_copies(book_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_book_copies_copy_number ON book_copies(copy_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_book_copies_barcode ON book_copies(barcode) WHERE deleted_at IS NULL;
CREATE INDEX idx_book_copies_status ON book_copies(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_book_copies_available ON book_copies(book_id, status) WHERE status = 'available' AND deleted_at IS NULL;

COMMENT ON TABLE book_copies IS 'Individual physical copies of books with tracking';
COMMENT ON COLUMN book_copies.copy_number IS 'Unique identifier for this physical copy across entire library';
COMMENT ON COLUMN book_copies.barcode IS 'Barcode for scanning system integration';
COMMENT ON COLUMN book_copies.total_borrows IS 'Lifetime borrowing count for this copy';

-- ============================================
-- Table: members
-- Description: Library members and their information
-- ============================================
CREATE TABLE members (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
    member_id VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(201) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    email email_address UNIQUE,
    phone phone_number,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    status member_status DEFAULT 'active' NOT NULL,
    membership_start_date DATE DEFAULT CURRENT_DATE NOT NULL,
    membership_expiry_date DATE,
    max_books_allowed INTEGER DEFAULT 3 NOT NULL,
    current_books_borrowed INTEGER DEFAULT 0 NOT NULL,
    total_books_borrowed INTEGER DEFAULT 0 NOT NULL,
    has_overdue_books BOOLEAN DEFAULT false NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT members_max_books_positive CHECK (max_books_allowed > 0),
    CONSTRAINT members_current_books_valid CHECK (current_books_borrowed >= 0 AND current_books_borrowed <= max_books_allowed),
    CONSTRAINT members_membership_dates CHECK (membership_expiry_date IS NULL OR membership_expiry_date >= membership_start_date)
);

-- Indexes
CREATE INDEX idx_members_member_id ON members(member_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_members_email ON members(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_members_full_name ON members(full_name) WHERE deleted_at IS NULL;
CREATE INDEX idx_members_status ON members(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_members_has_overdue ON members(has_overdue_books) WHERE has_overdue_books = true AND deleted_at IS NULL;
CREATE INDEX idx_members_full_name_trgm ON members USING GIN(full_name gin_trgm_ops);

COMMENT ON TABLE members IS 'Library members with contact information and borrowing status';
COMMENT ON COLUMN members.member_id IS 'Unique library member identifier (e.g., LIB001)';
COMMENT ON COLUMN members.max_books_allowed IS 'Maximum books this member can borrow simultaneously';
COMMENT ON COLUMN members.current_books_borrowed IS 'Current number of books on loan';
COMMENT ON COLUMN members.has_overdue_books IS 'Flag indicating if member has any overdue items';

-- ============================================
-- Table: borrowing_transactions
-- Description: Complete borrowing and return history
-- ============================================
CREATE TABLE borrowing_transactions (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
    member_id BIGINT NOT NULL REFERENCES members(id) ON DELETE RESTRICT,
    book_copy_id BIGINT NOT NULL REFERENCES book_copies(id) ON DELETE RESTRICT,
    book_id BIGINT NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
    status transaction_status DEFAULT 'active' NOT NULL,
    borrowed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    due_date DATE NOT NULL,
    returned_at TIMESTAMPTZ,
    days_overdue INTEGER DEFAULT 0 NOT NULL,
    renewal_count INTEGER DEFAULT 0 NOT NULL,
    librarian_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT borrowing_dates_valid CHECK (returned_at IS NULL OR returned_at >= borrowed_at),
    CONSTRAINT due_date_valid CHECK (due_date >= DATE(borrowed_at)),
    CONSTRAINT renewal_count_valid CHECK (renewal_count >= 0)
);

-- Indexes
CREATE INDEX idx_borrowing_member_id ON borrowing_transactions(member_id);
CREATE INDEX idx_borrowing_book_copy_id ON borrowing_transactions(book_copy_id);
CREATE INDEX idx_borrowing_book_id ON borrowing_transactions(book_id);
CREATE INDEX idx_borrowing_status ON borrowing_transactions(status);
CREATE INDEX idx_borrowing_due_date ON borrowing_transactions(due_date) WHERE status = 'active';
CREATE INDEX idx_borrowing_borrowed_at ON borrowing_transactions(borrowed_at DESC);
CREATE INDEX idx_borrowing_active_member ON borrowing_transactions(member_id, status) WHERE status = 'active';

COMMENT ON TABLE borrowing_transactions IS 'Complete history of all borrowing and return transactions';
COMMENT ON COLUMN borrowing_transactions.due_date IS 'Date when book must be returned';
COMMENT ON COLUMN borrowing_transactions.days_overdue IS 'Number of days book is/was overdue';

-- ============================================
-- Functions & Triggers
-- ============================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all relevant tables
CREATE TRIGGER authors_updated_at BEFORE UPDATE ON authors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER books_updated_at BEFORE UPDATE ON books
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER book_copies_updated_at BEFORE UPDATE ON book_copies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER members_updated_at BEFORE UPDATE ON members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER borrowing_transactions_updated_at BEFORE UPDATE ON borrowing_transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Update book copy counts when copies are added/removed
CREATE OR REPLACE FUNCTION update_book_copy_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        UPDATE books SET
            total_copies = (
                SELECT COUNT(*) FROM book_copies 
                WHERE book_id = NEW.book_id AND deleted_at IS NULL
            ),
            available_copies = (
                SELECT COUNT(*) FROM book_copies 
                WHERE book_id = NEW.book_id AND status = 'available' AND deleted_at IS NULL
            )
        WHERE id = NEW.book_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE books SET
            total_copies = (
                SELECT COUNT(*) FROM book_copies 
                WHERE book_id = OLD.book_id AND deleted_at IS NULL
            ),
            available_copies = (
                SELECT COUNT(*) FROM book_copies 
                WHERE book_id = OLD.book_id AND status = 'available' AND deleted_at IS NULL
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
    v_member_id BIGINT;
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
    v_member_status member_status;
    v_current_books INTEGER;
    v_max_books INTEGER;
    v_has_overdue BOOLEAN;
    v_copy_status copy_status;
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
-- Materialized Views for Statistics
-- ============================================

-- View: Popular books (weekly, monthly, yearly)
CREATE MATERIALIZED VIEW popular_books_stats AS
SELECT 
    b.id AS book_id,
    b.uuid AS book_uuid,
    b.title,
    b.isbn,
    g.name AS genre,
    -- Weekly stats
    COUNT(*) FILTER (
        WHERE bt.borrowed_at >= CURRENT_DATE - INTERVAL '7 days'
    ) AS borrows_last_week,
    -- Monthly stats
    COUNT(*) FILTER (
        WHERE bt.borrowed_at >= CURRENT_DATE - INTERVAL '30 days'
    ) AS borrows_last_month,
    -- Yearly stats
    COUNT(*) FILTER (
        WHERE bt.borrowed_at >= CURRENT_DATE - INTERVAL '1 year'
    ) AS borrows_last_year,
    -- All time
    COUNT(*) AS total_borrows,
    MAX(bt.borrowed_at) AS last_borrowed_at
FROM books b
LEFT JOIN borrowing_transactions bt ON b.id = bt.book_id
LEFT JOIN genres g ON b.genre_id = g.id
WHERE b.deleted_at IS NULL
GROUP BY b.id, b.uuid, b.title, b.isbn, g.name
WITH DATA;

CREATE UNIQUE INDEX idx_popular_books_stats_book_id ON popular_books_stats(book_id);
CREATE INDEX idx_popular_books_stats_week ON popular_books_stats(borrows_last_week DESC);
CREATE INDEX idx_popular_books_stats_month ON popular_books_stats(borrows_last_month DESC);
CREATE INDEX idx_popular_books_stats_year ON popular_books_stats(borrows_last_year DESC);

COMMENT ON MATERIALIZED VIEW popular_books_stats IS 'Popular books statistics by time period. Refresh daily.';

-- View: Genre popularity
CREATE MATERIALIZED VIEW genre_popularity_stats AS
SELECT 
    g.id AS genre_id,
    g.name AS genre_name,
    COUNT(DISTINCT b.id) AS total_books,
    COUNT(bt.id) FILTER (
        WHERE bt.borrowed_at >= CURRENT_DATE - INTERVAL '7 days'
    ) AS borrows_last_week,
    COUNT(bt.id) FILTER (
        WHERE bt.borrowed_at >= CURRENT_DATE - INTERVAL '30 days'
    ) AS borrows_last_month,
    COUNT(bt.id) FILTER (
        WHERE bt.borrowed_at >= CURRENT_DATE - INTERVAL '1 year'
    ) AS borrows_last_year,
    COUNT(bt.id) AS total_borrows
FROM genres g
LEFT JOIN books b ON g.id = b.genre_id AND b.deleted_at IS NULL
LEFT JOIN borrowing_transactions bt ON b.id = bt.book_id
GROUP BY g.id, g.name
WITH DATA;

CREATE UNIQUE INDEX idx_genre_popularity_stats_genre_id ON genre_popularity_stats(genre_id);

COMMENT ON MATERIALIZED VIEW genre_popularity_stats IS 'Genre popularity by borrowing frequency. Refresh daily.';

-- View: Member activity statistics
CREATE MATERIALIZED VIEW member_activity_stats AS
SELECT 
    DATE_TRUNC('day', bt.borrowed_at) AS activity_date,
    COUNT(DISTINCT bt.member_id) AS active_members,
    COUNT(*) AS total_borrows,
    COUNT(*) FILTER (WHERE bt.status = 'returned') AS total_returns,
    COUNT(*) FILTER (WHERE bt.status = 'active') AS currently_borrowed,
    COUNT(*) FILTER (WHERE bt.status = 'active' AND CURRENT_DATE > bt.due_date) AS overdue_count
FROM borrowing_transactions bt
GROUP BY DATE_TRUNC('day', bt.borrowed_at)
WITH DATA;

CREATE UNIQUE INDEX idx_member_activity_stats_date ON member_activity_stats(activity_date DESC);

COMMENT ON MATERIALIZED VIEW member_activity_stats IS 'Daily member activity and borrowing statistics. Refresh daily.';

-- ============================================
-- Useful Views (Non-Materialized)
-- ============================================

-- View: Current overdue books
CREATE VIEW overdue_books_current AS
SELECT 
    bt.id AS transaction_id,
    bt.uuid AS transaction_uuid,
    m.member_id,
    m.full_name AS member_name,
    m.email AS member_email,
    m.phone AS member_phone,
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
WHERE bt.status = 'active'
  AND bt.due_date < CURRENT_DATE
  AND m.deleted_at IS NULL
  AND b.deleted_at IS NULL
ORDER BY bt.due_date ASC;

COMMENT ON VIEW overdue_books_current IS 'Real-time view of all currently overdue books with member contact info';

-- View: Available books with copy counts
CREATE VIEW books_availability AS
SELECT 
    b.id,
    b.uuid,
    b.isbn,
    b.title,
    b.subtitle,
    g.name AS genre,
    b.publication_year,
    b.total_copies,
    b.available_copies,
    b.total_copies - b.available_copies AS borrowed_copies,
    STRING_AGG(a.full_name, ', ' ORDER BY ba.author_order) AS authors
FROM books b
LEFT JOIN genres g ON b.genre_id = g.id
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id AND a.deleted_at IS NULL
WHERE b.deleted_at IS NULL
GROUP BY b.id, b.uuid, b.isbn, b.title, b.subtitle, g.name, b.publication_year, 
         b.total_copies, b.available_copies;

COMMENT ON VIEW books_availability IS 'Real-time book availability with author names';

-- View: Member borrowing summary
CREATE VIEW member_borrowing_summary AS
SELECT 
    m.id,
    m.uuid,
    m.member_id,
    m.full_name,
    m.email,
    m.status,
    m.current_books_borrowed,
    m.max_books_allowed,
    m.max_books_allowed - m.current_books_borrowed AS available_slots,
    m.total_books_borrowed,
    m.has_overdue_books,
    (SELECT COUNT(*) FROM borrowing_transactions bt 
     WHERE bt.member_id = m.id AND bt.status = 'active' AND CURRENT_DATE > bt.due_date
    ) AS overdue_count
FROM members m
WHERE m.deleted_at IS NULL;

COMMENT ON VIEW member_borrowing_summary IS 'Real-time member borrowing status and limits';

-- ============================================
-- Helper Functions for Reporting
-- ============================================

-- Function: Get top books for a specific time period
CREATE OR REPLACE FUNCTION get_top_books(
    p_period VARCHAR DEFAULT 'month',
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    book_id BIGINT,
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
        STRING_AGG(a.full_name, ', ' ORDER BY ba.author_order) AS authors,
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
    WHERE b.deleted_at IS NULL
    GROUP BY b.id, b.title, g.name
    ORDER BY borrow_count DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_top_books IS 'Get top N books by borrow count for specified period (week/month/year/all)';

-- Function: Get member borrowing history
CREATE OR REPLACE FUNCTION get_member_history(p_member_id BIGINT)
RETURNS TABLE (
    transaction_id BIGINT,
    book_title VARCHAR,
    authors TEXT,
    copy_number VARCHAR,
    borrowed_at TIMESTAMPTZ,
    due_date DATE,
    returned_at TIMESTAMPTZ,
    days_overdue INTEGER,
    status transaction_status
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bt.id,
        b.title,
        STRING_AGG(a.full_name, ', ' ORDER BY ba.author_order),
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

COMMENT ON FUNCTION get_member_history IS 'Get complete borrowing history for a specific member';

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
    RAISE NOTICE 'Library Management System Schema';
    RAISE NOTICE 'Successfully created!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Tables created: 7';
    RAISE NOTICE 'Views created: 6 (3 materialized, 3 regular)';
    RAISE NOTICE 'Functions created: 7';
    RAISE NOTICE 'Triggers created: 11';
    RAISE NOTICE '========================================';
END $$;
