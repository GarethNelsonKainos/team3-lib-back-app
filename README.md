# Library Management System - RESTful API

A TypeScript RESTful API for managing a library system with books, authors, genres, members, copies, and transactions.

## Features

- Full CRUD operations for all entities (Authors, Genres, Books, Members, Copies, Transactions)
- Clean 4-layer architecture (Models → DAO → Services → Controllers)
- PostgreSQL database with pg-promise
- TypeScript for type safety
- Express.js for HTTP routing

## Prerequisites

- Node.js (v18 or higher)
- PostgreSQL database
- npm or yarn

## Installation

1. Clone the repository and install dependencies:
```bash
npm install
```

2. Set up your database configuration:
   - Copy `.env.example` to `.env`
   - Update the database credentials in `.env`

3. Create the database and tables:
   - Use the schema in `documents/schema.SQL`
   - Create the database and run the schema

## Running the Application

### Development mode (with auto-reload):
```bash
npm run dev
```

### Production mode:
```bash
npm run build
npm start
```

The server will start on `http://localhost:3000` (or the PORT specified in your .env file).

## API Endpoints

### Authors
- `GET /api/authors` - Get all authors
- `GET /api/authors/:id` - Get author by ID
- `POST /api/authors` - Create new author
- `PUT /api/authors/:id` - Update author
- `DELETE /api/authors/:id` - Delete author

### Genres
- `GET /api/genres` - Get all genres
- `GET /api/genres/:id` - Get genre by ID
- `POST /api/genres` - Create new genre
- `PUT /api/genres/:id` - Update genre
- `DELETE /api/genres/:id` - Delete genre

### Books
- `GET /api/books` - Get all books (with authors & genres)
- `GET /api/books/:id` - Get book by ID (with authors & genres)
- `POST /api/books` - Create new book (with authors & genres)
- `PUT /api/books/:id` - Update book (with authors & genres)
- `DELETE /api/books/:id` - Delete book

### Members
- `GET /api/members` - Get all members
- `GET /api/members/:id` - Get member by ID
- `POST /api/members` - Create new member
- `PUT /api/members/:id` - Update member
- `DELETE /api/members/:id` - Delete member

### Copies
- `GET /api/copies` - Get all copies
- `GET /api/copies/:id` - Get copy by ID
- `POST /api/copies` - Create new copy
- `PUT /api/copies/:id` - Update copy
- `DELETE /api/copies/:id` - Delete copy

### Transactions
- `GET /api/transactions` - Get all transactions
- `GET /api/transactions/:id` - Get transaction by ID
- `POST /api/transactions` - Create new transaction (checkout)
- `PUT /api/transactions/:id` - Update transaction (return book)
- `DELETE /api/transactions/:id` - Delete transaction

### Health Check
- `GET /health` - Check API health status

## Project Structure

```
src/
├── index.ts                    # Express app entry point & server setup
├── config/
│   └── database.ts            # pg-promise database configuration
├── models/                    # TypeScript interfaces/types
│   ├── Author.ts
│   ├── Genre.ts
│   ├── Book.ts
│   ├── Member.ts
│   ├── Copy.ts
│   └── Transaction.ts
├── dao/                       # Data Access Objects (database operations)
│   ├── AuthorDao.ts
│   ├── GenreDao.ts
│   ├── BookDao.ts
│   ├── MemberDao.ts
│   ├── CopyDao.ts
│   └── TransactionDao.ts
├── services/                  # Business logic layer
│   ├── AuthorService.ts
│   ├── GenreService.ts
│   ├── BookService.ts
│   ├── MemberService.ts
│   ├── CopyService.ts
│   └── TransactionService.ts
└── controllers/               # HTTP request handlers
    ├── AuthorController.ts
    ├── GenreController.ts
    ├── BookController.ts
    ├── MemberController.ts
    ├── CopyController.ts
    └── TransactionController.ts
```

## Example API Calls

### Create an Author
```bash
curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{"author_name": "J.K. Rowling"}'
```

### Create a Book with Authors and Genres
```bash
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Harry Potter and the Philosopher'\''s Stone",
    "isbn": "9780747532699",
    "publication_year": 1997,
    "description": "A young wizard'\''s journey begins",
    "author_ids": [1],
    "genre_ids": [1, 2]
  }'
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| DB_HOST | PostgreSQL host | localhost |
| DB_PORT | PostgreSQL port | 5432 |
| DB_NAME | Database name | library |
| DB_USER | Database user | postgres |
| DB_PASSWORD | Database password | postgres |
| PORT | Server port | 3000 |

## License

ISC

Team 3 Library Backend Application Feb/Marc 2026
