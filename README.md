# team3-lib-back-app
Team 3 Library Backend Application Feb/Marc 2026

## Status
Basic Express + TypeScript server bootstrapped. Health route and books list endpoint implemented.

## Remaining Work (API Layer)

### Core Endpoints
- Books
- Members
- Copies
- Borrowing (checkout/checkin)
- Reports

### Books
- POST /api/books (create book)
- GET /api/books/:id (single book detail)
- PATCH /api/books/:id (edit book)
- DELETE /api/books/:id (delete book with active-borrow validation)
- Add pagination/sorting options as needed
- Add input validation and consistent error responses

### Members
- POST /api/members (register member)
- GET /api/members (list/search)
- GET /api/members/:id (profile)
- PATCH /api/members/:id (update member)
- DELETE /api/members/:id (block if active borrows)
- Add borrowing summary to member profile

### Copies
- POST /api/books/:id/copies (add copies)
- GET /api/books/:id/copies (list copies)
- GET /api/copies/:id (copy detail)
- PATCH /api/copies/:id/status (update status)
- Copy history endpoint (borrowing records)

### Borrowing
- POST /api/borrows/checkout
- POST /api/borrows/checkin
- Borrowing rules enforcement
	- Max 3 active borrows per member
	- Block checkout if overdue items exist
	- Set due date to 14 days by default
- Transactional updates (copy status + borrowing record)

### Reports
- Most borrowed books (weekly/monthly/annual)
- Popular genres/authors
- Overdue items summary
- Inventory status (available vs borrowed)
- Collection gaps (never borrowed, high demand)

### Validation and Error Handling
- Request validation (schema-based preferred)
- Friendly errors for common constraints (duplicate ISBN, invalid member ID)
- Consistent error response shape

### Security and Ops
- Add auth/roles if required
- Rate limiting for public endpoints
- CORS config for frontend domain
- Logging and request IDs

### Testing and Docs
- Unit/integration tests for routes
- API documentation (OpenAPI/Swagger)
- Example Insomnia collection

## Local Development
- npm install
- npm run dev

## Notes
- Database schema in documents/schema.SQL may differ from the current DB. Keep API queries aligned with the actual DB schema.
