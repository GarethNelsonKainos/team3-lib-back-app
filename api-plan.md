# RESTful API Implementation Plan - Library Management System

## Project Structure
```
src/
├── index.ts                    # Express app entry point & server setup
├── config/
│   └── database.ts            # pg-promise database connection configuration
├── models/
│   ├── Author.ts              # Author type/interface
│   ├── Genre.ts               # Genre type/interface
│   ├── Book.ts                # Book type/interface
│   ├── Member.ts              # Member type/interface
│   ├── Copy.ts                # Copy type/interface
│   └── Transaction.ts         # Transaction type/interface
├── dao/
│   ├── AuthorDao.ts           # Author database operations
│   ├── GenreDao.ts            # Genre database operations
│   ├── BookDao.ts             # Book database operations (+ book_authors, book_genres)
│   ├── MemberDao.ts           # Member database operations
│   ├── CopyDao.ts             # Copy database operations
│   └── TransactionDao.ts      # Transaction database operations
├── services/
│   ├── AuthorService.ts       # Author business logic
│   ├── GenreService.ts        # Genre business logic
│   ├── BookService.ts         # Book business logic (handles authors/genres joins)
│   ├── MemberService.ts       # Member business logic
│   ├── CopyService.ts         # Copy business logic
│   └── TransactionService.ts  # Transaction business logic
└── controllers/
    ├── AuthorController.ts    # Author route handlers
    ├── GenreController.ts     # Genre route handlers
    ├── BookController.ts      # Book route handlers
    ├── MemberController.ts    # Member route handlers
    ├── CopyController.ts      # Copy route handlers
    └── TransactionController.ts # Transaction route handlers

test/                          # (Placeholder for future tests)
```

## RESTful API Endpoints

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
- `GET /api/books` - Get all books (with authors & genres joined)
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

## Layer Responsibilities

### Models
- TypeScript interfaces/types defining data structure for each table
- Matches database schema fields

### DAO (Data Access Object)
- Direct database queries using pg-promise
- CRUD operations: `findAll()`, `findById()`, `create()`, `update()`, `delete()`
- Handles SQL queries and returns raw data

### Services
- Business logic layer
- Calls DAO methods
- Handles data transformation between DAO and Controllers
- For Books: manages relationships with book_authors and book_genres junction tables

### Controllers
- HTTP request/response handling
- Calls Service methods
- Returns JSON responses
- HTTP status codes (200, 201, 404, 500, etc.)

## Dependencies Needed
```json
{
  "dependencies": {
    "express",
    "pg-promise"
  },
  "devDependencies": {
    "@types/express",
    "@types/pg-promise"
  }
}
```

## Implementation Notes
- Using pg-promise for PostgreSQL database operations
- All entities have full CRUD operations
- Basic CRUD only (no additional features for now)
- No testing framework yet (placeholder test/ directory)
- No validation, pagination, or authentication at this stage
