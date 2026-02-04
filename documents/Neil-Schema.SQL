-- Schema for Book Library Web App (PostgreSQL)

CREATE TABLE authors (
    author_id BIGSERIAL PRIMARY KEY,
    author_name TEXT NOT NULL
);

CREATE TABLE genres (
    genre_id BIGSERIAL PRIMARY KEY,
    genre_name TEXT NOT NULL UNIQUE
);

CREATE TABLE books (
    book_id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    isbn TEXT NOT NULL UNIQUE,
    publication_year INTEGER,
    description TEXT
);

CREATE TABLE book_authors (
    book_id BIGINT NOT NULL REFERENCES books(book_id) ON DELETE CASCADE,
    author_id BIGINT NOT NULL REFERENCES authors(author_id) ON DELETE RESTRICT,
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE book_genres (
    book_id BIGINT NOT NULL REFERENCES books(book_id) ON DELETE CASCADE,
    genre_id BIGINT NOT NULL REFERENCES genres(genre_id) ON DELETE RESTRICT,
    PRIMARY KEY (book_id, genre_id)
);

CREATE TABLE members (
    member_id BIGSERIAL PRIMARY KEY,
    member_identifier TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    contact_information TEXT NOT NULL,
    address TEXT NOT NULL,
    join_date DATE NOT NULL,
    expiry_date DATE NOT NULL
);

CREATE TABLE copies (
    copy_id BIGSERIAL PRIMARY KEY,
    copy_identifier TEXT NOT NULL UNIQUE,
    book_id BIGINT NOT NULL REFERENCES books(book_id) ON DELETE RESTRICT,
    status TEXT NOT NULL CHECK (status IN ('Available', 'Borrowed'))
);

CREATE TABLE transactions (
    transaction_id BIGSERIAL PRIMARY KEY,
    member_id BIGINT NOT NULL REFERENCES members(member_id) ON DELETE RESTRICT,
    copy_id BIGINT NOT NULL REFERENCES copies(copy_id) ON DELETE RESTRICT,
    checkout_timestamp TIMESTAMP NOT NULL,
    due_date DATE NOT NULL,
    return_timestamp TIMESTAMP NULL,
    CHECK (return_timestamp IS NULL OR return_timestamp >= checkout_timestamp)
);

CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_publication_year ON books(publication_year);
CREATE INDEX idx_authors_name ON authors(author_name);
CREATE INDEX idx_members_name ON members(full_name);
CREATE INDEX idx_transactions_member ON transactions(member_id);
CREATE INDEX idx_transactions_copy ON transactions(copy_id);
