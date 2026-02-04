-- Migration 001: Initial Schema
-- Creates all base tables for the library management system

-- Function for auto-updating timestamps
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- AUTHORS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS authors (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER authors_set_updated_at
    BEFORE UPDATE ON authors
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================
-- BOOKS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS books (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    genre VARCHAR(100),
    publication_year INTEGER,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT books_publication_year_check 
        CHECK (publication_year IS NULL OR (publication_year >= 1000 AND publication_year <= EXTRACT(year FROM NOW())::integer))
);

CREATE TRIGGER books_set_updated_at
    BEFORE UPDATE ON books
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================
-- BOOK_AUTHORS JUNCTION TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS book_authors (
    book_id BIGINT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    author_id BIGINT NOT NULL REFERENCES authors(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, author_id)
);

-- ============================================
-- BOOK_COPIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS book_copies (
    id BIGSERIAL PRIMARY KEY,
    book_id BIGINT NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
    copy_number VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT book_copies_status_check 
        CHECK (status IN ('AVAILABLE', 'BORROWED'))
);

CREATE TRIGGER book_copies_set_updated_at
    BEFORE UPDATE ON book_copies
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================
-- MEMBERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS members (
    id BIGSERIAL PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    membership_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT members_email_unique UNIQUE (email)
);

-- Partial unique index for non-null emails (case-insensitive)
CREATE UNIQUE INDEX IF NOT EXISTS ux_members_email_not_null 
    ON members (LOWER(email)) 
    WHERE email IS NOT NULL;

CREATE TRIGGER members_set_updated_at
    BEFORE UPDATE ON members
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================
-- BORROWING_RECORDS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS borrowing_records (
    id BIGSERIAL PRIMARY KEY,
    book_copy_id BIGINT NOT NULL REFERENCES book_copies(id) ON DELETE RESTRICT,
    member_id BIGINT NOT NULL REFERENCES members(id) ON DELETE RESTRICT,
    borrowed_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    returned_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'BORROWED',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT borrowing_records_status_check 
        CHECK (status IN ('BORROWED', 'RETURNED', 'OVERDUE')),
    CONSTRAINT borrowing_records_due_date_check 
        CHECK (due_date >= borrowed_date),
    CONSTRAINT borrowing_records_returned_date_check 
        CHECK (returned_date IS NULL OR returned_date >= borrowed_date)
);

-- Ensure a copy can only have one active borrow
CREATE UNIQUE INDEX IF NOT EXISTS uq_borrowing_records_active_copy 
    ON borrowing_records (book_copy_id) 
    WHERE returned_date IS NULL;

CREATE TRIGGER borrowing_records_set_updated_at
    BEFORE UPDATE ON borrowing_records
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();
