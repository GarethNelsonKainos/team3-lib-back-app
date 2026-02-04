-- Migration 002: Performance Indexes
-- Creates indexes for common query patterns

-- ============================================
-- BOOKS INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_books_title ON books(title);
CREATE INDEX IF NOT EXISTS idx_books_isbn ON books(isbn);
CREATE INDEX IF NOT EXISTS idx_books_genre ON books(genre);
CREATE INDEX IF NOT EXISTS idx_books_publication_year ON books(publication_year);

-- Full-text search index for books
CREATE INDEX IF NOT EXISTS idx_books_title_trgm ON books USING gin (title gin_trgm_ops);

-- ============================================
-- AUTHORS INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_authors_name ON authors(name);

-- ============================================
-- BOOK_COPIES INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_book_copies_book_id ON book_copies(book_id);
CREATE INDEX IF NOT EXISTS idx_book_copies_status ON book_copies(status);
CREATE INDEX IF NOT EXISTS idx_book_copies_available ON book_copies(book_id) WHERE status = 'AVAILABLE';

-- ============================================
-- MEMBERS INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_members_member_id ON members(member_id);
CREATE INDEX IF NOT EXISTS idx_members_email ON members(email);
CREATE INDEX IF NOT EXISTS idx_members_last_name ON members(last_name);
CREATE INDEX IF NOT EXISTS idx_members_name ON members(last_name, first_name);

-- ============================================
-- BORROWING_RECORDS INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_borrowing_records_member_id ON borrowing_records(member_id);
CREATE INDEX IF NOT EXISTS idx_borrowing_records_copy_id ON borrowing_records(book_copy_id);
CREATE INDEX IF NOT EXISTS idx_borrowing_records_status ON borrowing_records(status);
CREATE INDEX IF NOT EXISTS idx_borrowing_records_due_date ON borrowing_records(due_date);
CREATE INDEX IF NOT EXISTS idx_borrowing_records_borrowed_date ON borrowing_records(borrowed_date);

-- Partial indexes for active borrows (performance optimization)
CREATE INDEX IF NOT EXISTS idx_borrowing_active_member ON borrowing_records(member_id) WHERE returned_date IS NULL;
CREATE INDEX IF NOT EXISTS idx_borrowing_due_active ON borrowing_records(due_date) WHERE returned_date IS NULL;
CREATE INDEX IF NOT EXISTS idx_borrowing_overdue ON borrowing_records(member_id, due_date) WHERE status = 'OVERDUE';
