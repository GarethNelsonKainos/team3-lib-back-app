-- Development Seed Data for Library System
-- This file populates the database with sample data for testing

-- Ensure we start fresh (optional - comment out if you want to preserve existing data)
-- TRUNCATE borrowing_records, book_copies, book_authors, books, authors, members RESTART IDENTITY CASCADE;

BEGIN;

-- ============================================
-- AUTHORS
-- ============================================
INSERT INTO authors (name) VALUES
    ('George Orwell'),
    ('Jane Austen'),
    ('F. Scott Fitzgerald'),
    ('Harper Lee'),
    ('J.K. Rowling'),
    ('Stephen King'),
    ('Agatha Christie'),
    ('Ernest Hemingway'),
    ('Mark Twain'),
    ('Virginia Woolf'),
    ('Gabriel García Márquez'),
    ('Toni Morrison'),
    ('J.R.R. Tolkien'),
    ('Isaac Asimov'),
    ('Ray Bradbury'),
    ('Margaret Atwood'),
    ('Chimamanda Ngozi Adichie'),
    ('Haruki Murakami'),
    ('Neil Gaiman'),
    ('Terry Pratchett')
ON CONFLICT DO NOTHING;

-- ============================================
-- BOOKS
-- ============================================
INSERT INTO books (title, isbn, genre, publication_year, description) VALUES
    ('1984', '978-0451524935', 'Dystopian Fiction', 1949, 'A dystopian social science fiction novel and cautionary tale about the dangers of totalitarianism.'),
    ('Pride and Prejudice', '978-0141439518', 'Classic Romance', 1813, 'A romantic novel following the character development of Elizabeth Bennet.'),
    ('The Great Gatsby', '978-0743273565', 'Classic Fiction', 1925, 'A novel about the American Dream set in the Jazz Age.'),
    ('To Kill a Mockingbird', '978-0446310789', 'Southern Gothic', 1960, 'A novel about racial injustice in the American South.'),
    ('Harry Potter and the Philosopher''s Stone', '978-0747532699', 'Fantasy', 1997, 'The first novel in the Harry Potter series about a young wizard.'),
    ('The Shining', '978-0307743657', 'Horror', 1977, 'A horror novel about a family staying at an isolated hotel.'),
    ('Murder on the Orient Express', '978-0062693662', 'Mystery', 1934, 'A detective novel featuring Hercule Poirot.'),
    ('The Old Man and the Sea', '978-0684801223', 'Literary Fiction', 1952, 'A short novel about an aging Cuban fisherman.'),
    ('Adventures of Huckleberry Finn', '978-0486280615', 'Adventure', 1884, 'A novel about a boy''s adventures along the Mississippi River.'),
    ('Mrs Dalloway', '978-0156628709', 'Modernist Fiction', 1925, 'A novel detailing a day in the life of Clarissa Dalloway.'),
    ('One Hundred Years of Solitude', '978-0060883287', 'Magical Realism', 1967, 'A multi-generational story of the Buendía family.'),
    ('Beloved', '978-1400033416', 'Historical Fiction', 1987, 'A novel about the aftermath of slavery.'),
    ('The Hobbit', '978-0547928227', 'Fantasy', 1937, 'A fantasy novel about the adventures of Bilbo Baggins.'),
    ('Foundation', '978-0553293357', 'Science Fiction', 1951, 'A science fiction novel about the fall of a Galactic Empire.'),
    ('Fahrenheit 451', '978-1451673319', 'Dystopian Fiction', 1953, 'A dystopian novel about a future American society where books are outlawed.'),
    ('The Handmaid''s Tale', '978-0385490818', 'Dystopian Fiction', 1985, 'A dystopian novel set in a totalitarian theocracy.'),
    ('Americanah', '978-0307455925', 'Contemporary Fiction', 2013, 'A novel about a young Nigerian woman''s experiences in America.'),
    ('Norwegian Wood', '978-0375704024', 'Contemporary Fiction', 1987, 'A nostalgic story of loss and sexuality.'),
    ('American Gods', '978-0063081918', 'Fantasy', 2001, 'A novel blending American folklore with fantasy.'),
    ('Good Omens', '978-0060853983', 'Comedy Fantasy', 1990, 'A comedic novel about the coming of the apocalypse.')
ON CONFLICT (isbn) DO NOTHING;

-- ============================================
-- BOOK-AUTHOR RELATIONSHIPS
-- ============================================
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b, authors a WHERE b.title = '1984' AND a.name = 'George Orwell'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Pride and Prejudice' AND a.name = 'Jane Austen'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'The Great Gatsby' AND a.name = 'F. Scott Fitzgerald'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'To Kill a Mockingbird' AND a.name = 'Harper Lee'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Harry Potter and the Philosopher''s Stone' AND a.name = 'J.K. Rowling'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'The Shining' AND a.name = 'Stephen King'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Murder on the Orient Express' AND a.name = 'Agatha Christie'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'The Old Man and the Sea' AND a.name = 'Ernest Hemingway'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Adventures of Huckleberry Finn' AND a.name = 'Mark Twain'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Mrs Dalloway' AND a.name = 'Virginia Woolf'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'One Hundred Years of Solitude' AND a.name = 'Gabriel García Márquez'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Beloved' AND a.name = 'Toni Morrison'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'The Hobbit' AND a.name = 'J.R.R. Tolkien'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Foundation' AND a.name = 'Isaac Asimov'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Fahrenheit 451' AND a.name = 'Ray Bradbury'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'The Handmaid''s Tale' AND a.name = 'Margaret Atwood'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Americanah' AND a.name = 'Chimamanda Ngozi Adichie'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Norwegian Wood' AND a.name = 'Haruki Murakami'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'American Gods' AND a.name = 'Neil Gaiman'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Good Omens' AND a.name = 'Neil Gaiman'
UNION ALL
SELECT b.id, a.id FROM books b, authors a WHERE b.title = 'Good Omens' AND a.name = 'Terry Pratchett'
ON CONFLICT DO NOTHING;

-- ============================================
-- BOOK COPIES (2-4 copies per book)
-- ============================================
INSERT INTO book_copies (book_id, copy_number, status)
SELECT b.id, b.isbn || '-001', 'AVAILABLE' FROM books b
UNION ALL
SELECT b.id, b.isbn || '-002', 'AVAILABLE' FROM books b
UNION ALL
SELECT b.id, b.isbn || '-003', 'AVAILABLE' FROM books b WHERE b.genre IN ('Fantasy', 'Dystopian Fiction', 'Mystery')
UNION ALL
SELECT b.id, b.isbn || '-004', 'AVAILABLE' FROM books b WHERE b.title IN ('Harry Potter and the Philosopher''s Stone', '1984', 'The Hobbit')
ON CONFLICT (copy_number) DO NOTHING;

-- ============================================
-- MEMBERS
-- ============================================
INSERT INTO members (member_id, first_name, last_name, email, phone, address, membership_date) VALUES
    ('MEM001', 'Alice', 'Johnson', 'alice.johnson@email.com', '555-0101', '123 Oak Street, Springfield', '2024-01-15'),
    ('MEM002', 'Bob', 'Smith', 'bob.smith@email.com', '555-0102', '456 Maple Avenue, Springfield', '2024-02-20'),
    ('MEM003', 'Carol', 'Williams', 'carol.williams@email.com', '555-0103', '789 Pine Road, Springfield', '2024-03-10'),
    ('MEM004', 'David', 'Brown', 'david.brown@email.com', '555-0104', '321 Elm Street, Springfield', '2024-04-05'),
    ('MEM005', 'Emma', 'Davis', 'emma.davis@email.com', '555-0105', '654 Cedar Lane, Springfield', '2024-05-12'),
    ('MEM006', 'Frank', 'Miller', 'frank.miller@email.com', '555-0106', '987 Birch Court, Springfield', '2024-06-18'),
    ('MEM007', 'Grace', 'Wilson', 'grace.wilson@email.com', '555-0107', '147 Walnut Drive, Springfield', '2024-07-22'),
    ('MEM008', 'Henry', 'Moore', 'henry.moore@email.com', '555-0108', '258 Cherry Street, Springfield', '2024-08-30'),
    ('MEM009', 'Ivy', 'Taylor', 'ivy.taylor@email.com', '555-0109', '369 Ash Avenue, Springfield', '2024-09-14'),
    ('MEM010', 'Jack', 'Anderson', 'jack.anderson@email.com', '555-0110', '741 Spruce Road, Springfield', '2024-10-08'),
    ('MEM011', 'Karen', 'Thomas', 'karen.thomas@email.com', '555-0111', '852 Willow Lane, Springfield', '2024-11-25'),
    ('MEM012', 'Leo', 'Jackson', 'leo.jackson@email.com', '555-0112', '963 Hickory Court, Springfield', '2024-12-03'),
    ('MEM013', 'Mia', 'White', 'mia.white@email.com', '555-0113', '159 Poplar Street, Springfield', '2025-01-07'),
    ('MEM014', 'Noah', 'Harris', 'noah.harris@email.com', '555-0114', '267 Sycamore Avenue, Springfield', '2025-02-14'),
    ('MEM015', 'Olivia', 'Martin', 'olivia.martin@email.com', '555-0115', '378 Magnolia Drive, Springfield', '2025-03-20')
ON CONFLICT (member_id) DO NOTHING;

-- ============================================
-- BORROWING RECORDS
-- Mix of: returned, currently borrowed, and overdue
-- ============================================

-- Get some copy and member IDs for borrowing records
DO $$
DECLARE
    v_copy_id BIGINT;
    v_member_id BIGINT;
BEGIN
    -- Past completed borrows (returned on time)
    FOR i IN 1..15 LOOP
        SELECT bc.id INTO v_copy_id FROM book_copies bc ORDER BY RANDOM() LIMIT 1;
        SELECT m.id INTO v_member_id FROM members m ORDER BY RANDOM() LIMIT 1;
        
        INSERT INTO borrowing_records (book_copy_id, member_id, borrowed_date, due_date, returned_date, status)
        VALUES (
            v_copy_id,
            v_member_id,
            CURRENT_DATE - (30 + i * 5),
            CURRENT_DATE - (16 + i * 5),
            CURRENT_DATE - (18 + i * 5),
            'RETURNED'
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
END $$;

-- Current active borrows (not yet due)
INSERT INTO borrowing_records (book_copy_id, member_id, borrowed_date, due_date, status)
SELECT 
    bc.id,
    m.id,
    CURRENT_DATE - 5,
    CURRENT_DATE + 9,
    'BORROWED'
FROM book_copies bc
CROSS JOIN members m
WHERE bc.copy_number LIKE '%-001'
  AND m.member_id IN ('MEM001', 'MEM002', 'MEM003')
  AND NOT EXISTS (
      SELECT 1 FROM borrowing_records br 
      WHERE br.book_copy_id = bc.id AND br.returned_date IS NULL
  )
LIMIT 6
ON CONFLICT DO NOTHING;

-- Update copy statuses for active borrows
UPDATE book_copies bc
SET status = 'BORROWED'
WHERE EXISTS (
    SELECT 1 FROM borrowing_records br
    WHERE br.book_copy_id = bc.id AND br.returned_date IS NULL
);

-- Add some overdue borrows for testing
INSERT INTO borrowing_records (book_copy_id, member_id, borrowed_date, due_date, status)
SELECT 
    bc.id,
    m.id,
    CURRENT_DATE - 20,
    CURRENT_DATE - 6,
    'OVERDUE'
FROM book_copies bc
CROSS JOIN members m
WHERE bc.copy_number LIKE '%-002'
  AND bc.status = 'AVAILABLE'
  AND m.member_id IN ('MEM004', 'MEM005')
  AND NOT EXISTS (
      SELECT 1 FROM borrowing_records br 
      WHERE br.book_copy_id = bc.id AND br.returned_date IS NULL
  )
LIMIT 3
ON CONFLICT DO NOTHING;

-- Update copy statuses for overdue borrows
UPDATE book_copies bc
SET status = 'BORROWED'
WHERE EXISTS (
    SELECT 1 FROM borrowing_records br
    WHERE br.book_copy_id = bc.id 
      AND br.returned_date IS NULL 
      AND br.status = 'OVERDUE'
);

COMMIT;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
SELECT 'Seed data loaded successfully!' AS status;

SELECT 'Books' AS entity, COUNT(*) AS count FROM books
UNION ALL SELECT 'Authors', COUNT(*) FROM authors
UNION ALL SELECT 'Book Copies', COUNT(*) FROM book_copies
UNION ALL SELECT 'Members', COUNT(*) FROM members
UNION ALL SELECT 'Borrowing Records', COUNT(*) FROM borrowing_records;

SELECT 'Active Borrows' AS metric, COUNT(*) AS count 
FROM borrowing_records WHERE returned_date IS NULL
UNION ALL
SELECT 'Overdue Items', COUNT(*) 
FROM borrowing_records WHERE returned_date IS NULL AND due_date < CURRENT_DATE;
