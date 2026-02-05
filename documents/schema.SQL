-- Schema for Book Library Web App (PostgreSQL)

CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    author_name TEXT NOT NULL
);

CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name TEXT NOT NULL UNIQUE
);

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    isbn TEXT NOT NULL UNIQUE,
     publication_year INTEGER,
     description TEXT
);

CREATE TABLE book_authors (
    book_id INTEGER NOT NULL REFERENCES books(book_id),
    author_id INTEGER NOT NULL REFERENCES authors(author_id),
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE book_genres (
    book_id INTEGER NOT NULL REFERENCES books(book_id),
    genre_id INTEGER NOT NULL REFERENCES genres(genre_id),
    PRIMARY KEY (book_id, genre_id)
);

CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
     contact_information TEXT,
     address_line_1 TEXT,
     address_line_2 TEXT,
     city TEXT NOT NULL,
     post_code TEXT NOT NULL,
     join_date DATE NOT NULL,
     expiry_date DATE NOT NULL
);

CREATE TABLE copies (
    copy_id SERIAL PRIMARY KEY,
    copy_identifier TEXT NOT NULL UNIQUE,
    book_id INTEGER NOT NULL REFERENCES books(book_id),
    status TEXT NOT NULL
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    member_id INTEGER NOT NULL REFERENCES members(member_id),
    copy_id INTEGER NOT NULL REFERENCES copies(copy_id),
    checkout_timestamp TIMESTAMP NOT NULL,
    due_date TIMESTAMP NOT NULL,
    return_timestamp TIMESTAMP NULL
);

