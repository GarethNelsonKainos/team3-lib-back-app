-- Seed data for Book Library Web App

-- Insert Authors
INSERT INTO authors (author_name) VALUES
('J.K. Rowling'),
('George Orwell'),
('Jane Austen'),
('F. Scott Fitzgerald'),
('Harper Lee'),
('J.R.R. Tolkien'),
('Agatha Christie'),
('Stephen King'),
('Margaret Atwood'),
('Neil Gaiman');

-- Insert Genres
INSERT INTO genres (genre_name) VALUES
('Fantasy'),
('Science Fiction'),
('Mystery'),
('Classic Literature'),
('Horror'),
('Romance'),
('Thriller'),
('Historical Fiction'),
('Young Adult'),
('Dystopian');

-- Insert Books
INSERT INTO books (title, isbn, publication_year, description) VALUES
('Harry Potter and the Philosopher''s Stone', '978-0-7475-3269-9', 1997, 'A young wizard discovers his magical heritage on his 11th birthday.'),
('1984', '978-0-452-28423-4', 1949, 'A dystopian social science fiction novel set in a totalitarian society.'),
('Pride and Prejudice', '978-0-14-143951-8', 1813, 'A romantic novel following the character development of Elizabeth Bennet.'),
('The Great Gatsby', '978-0-7432-7356-5', 1925, 'A tragic story of Jay Gatsby and his pursuit of the American Dream.'),
('To Kill a Mockingbird', '978-0-06-112008-4', 1960, 'A novel about racial injustice in the American South.'),
('The Hobbit', '978-0-547-92822-7', 1937, 'A fantasy novel about the quest of home-loving Bilbo Baggins.'),
('Murder on the Orient Express', '978-0-06-207348-8', 1934, 'A detective novel featuring Hercule Poirot solving a murder on a train.'),
('The Shining', '978-0-385-12167-5', 1977, 'A horror novel about a family in an isolated hotel with a dark past.'),
('The Handmaid''s Tale', '978-0-385-49081-8', 1985, 'A dystopian novel set in a totalitarian society where women have lost all rights.'),
('American Gods', '978-0-380-97365-0', 2001, 'A fantasy novel about old gods versus new gods in modern America.');

-- Insert Book-Author relationships
INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1),  -- Harry Potter - J.K. Rowling
(2, 2),  -- 1984 - George Orwell
(3, 3),  -- Pride and Prejudice - Jane Austen
(4, 4),  -- The Great Gatsby - F. Scott Fitzgerald
(5, 5),  -- To Kill a Mockingbird - Harper Lee
(6, 6),  -- The Hobbit - J.R.R. Tolkien
(7, 7),  -- Murder on the Orient Express - Agatha Christie
(8, 8),  -- The Shining - Stephen King
(9, 9),  -- The Handmaid's Tale - Margaret Atwood
(10, 10); -- American Gods - Neil Gaiman

-- Insert Book-Genre relationships
INSERT INTO book_genres (book_id, genre_id) VALUES
(1, 1),  -- Harry Potter - Fantasy
(1, 9),  -- Harry Potter - Young Adult
(2, 2),  -- 1984 - Science Fiction
(2, 10), -- 1984 - Dystopian
(3, 4),  -- Pride and Prejudice - Classic Literature
(3, 6),  -- Pride and Prejudice - Romance
(4, 4),  -- The Great Gatsby - Classic Literature
(5, 4),  -- To Kill a Mockingbird - Classic Literature
(5, 8),  -- To Kill a Mockingbird - Historical Fiction
(6, 1),  -- The Hobbit - Fantasy
(7, 3),  -- Murder on the Orient Express - Mystery
(8, 5),  -- The Shining - Horror
(9, 2),  -- The Handmaid's Tale - Science Fiction
(9, 10), -- The Handmaid's Tale - Dystopian
(10, 1); -- American Gods - Fantasy

-- Insert Members
INSERT INTO members (full_name, contact_information, address_line_1, address_line_2, city, post_code, join_date, expiry_date) VALUES
('Alice Johnson', 'alice.j@email.com', '123 Oak Street', 'Apt 4B', 'Dublin', 'D02 XY45', '2025-01-15', '2026-01-15'),
('Bob Smith', 'bob.smith@email.com', '456 Elm Avenue', NULL, 'Cork', 'T12 AB34', '2025-03-20', '2026-03-20'),
('Carol Williams', 'carol.w@email.com', '789 Maple Drive', 'Unit 12', 'Galway', 'H91 CD56', '2024-11-10', '2025-11-10'),
('David Brown', 'david.brown@email.com', '321 Pine Road', NULL, 'Limerick', 'V94 EF78', '2025-06-05', '2026-06-05'),
('Emma Davis', 'emma.d@email.com', '654 Birch Lane', 'Suite 3', 'Waterford', 'X91 GH90', '2025-02-28', '2026-02-28'),
('Frank Miller', 'frank.m@email.com', '987 Cedar Court', NULL, 'Dublin', 'D08 IJ12', '2024-09-15', '2025-09-15'),
('Grace Wilson', 'grace.w@email.com', '147 Willow Street', 'Flat 7', 'Cork', 'T23 KL34', '2025-04-12', '2026-04-12'),
('Henry Moore', 'henry.moore@email.com', '258 Ash Boulevard', NULL, 'Galway', 'H54 MN56', '2025-01-08', '2026-01-08');

-- Insert Copies
INSERT INTO copies (copy_identifier, book_id, status) VALUES
('HP001', 1, 'Available'),
('HP002', 1, 'Borrowed'),
('HP003', 1, 'Available'),
('1984-001', 2, 'Available'),
('1984-002', 2, 'Borrowed'),
('PP001', 3, 'Available'),
('GG001', 4, 'Available'),
('GG002', 4, 'Available'),
('TKM001', 5, 'Borrowed'),
('HOB001', 6, 'Available'),
('HOB002', 6, 'Available'),
('MOTE001', 7, 'Available'),
('SHIN001', 8, 'Borrowed'),
('HT001', 9, 'Available'),
('HT002', 9, 'Available'),
('AG001', 10, 'Available');

-- Insert Transactions (some ongoing, some completed)
INSERT INTO transactions (member_id, copy_id, checkout_timestamp, due_date, return_timestamp) VALUES
-- Completed transactions
(1, 1, '2025-12-01 10:30:00', '2025-12-15 23:59:59', '2025-12-14 14:20:00'),
(2, 4, '2025-12-10 09:15:00', '2025-12-24 23:59:59', '2025-12-20 11:45:00'),
(3, 6, '2025-11-15 14:20:00', '2025-11-29 23:59:59', '2025-11-28 16:30:00'),
(4, 10, '2025-12-05 11:00:00', '2025-12-19 23:59:59', '2025-12-18 10:15:00'),
(5, 14, '2025-11-20 13:45:00', '2025-12-04 23:59:59', '2025-12-03 15:20:00'),

-- Active/ongoing transactions (no return_timestamp)
(2, 2, '2026-01-15 10:00:00', '2026-01-29 23:59:59', NULL),
(4, 5, '2026-01-20 14:30:00', '2026-02-03 23:59:59', NULL),
(6, 9, '2026-01-25 09:45:00', '2026-02-08 23:59:59', NULL),
(7, 13, '2026-01-28 16:20:00', '2026-02-11 23:59:59', NULL),

-- Overdue transaction
(8, 7, '2026-01-10 11:30:00', '2026-01-24 23:59:59', NULL);