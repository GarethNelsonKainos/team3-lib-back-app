# Library Management System - Entity Relationship Diagram

## Database Schema Visualization

```mermaid
erDiagram
    books ||--o{ book_copies : "has copies"
    books ||--o{ book_authors : "written by"
    books }o--|| genres : "belongs to"
    books ||--o{ borrowing_transactions : "tracked in"
    authors ||--o{ book_authors : "authors"
    book_copies ||--o{ borrowing_transactions : "borrowed as"
    members ||--o{ borrowing_transactions : "borrows"
    
    books {
        bigserial id PK
        uuid uuid UK
        varchar isbn UK "ISBN-10/13"
        varchar title "Book title"
        varchar subtitle
        integer genre_id FK
        integer publication_year
        varchar publisher
        integer total_copies "Auto-computed"
        integer available_copies "Auto-computed"
        tsvector search_vector "Full-text search"
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at "Soft delete"
    }
    
    book_copies {
        bigserial id PK
        uuid uuid UK
        bigint book_id FK
        varchar copy_number UK "e.g. BK001-C01"
        varchar barcode UK "Scannable barcode"
        copy_status status "available|borrowed|maintenance|lost"
        text condition_notes
        date acquisition_date
        decimal purchase_price
        varchar location "Shelf location"
        timestamptz last_borrowed_at
        integer total_borrows "Lifetime borrows"
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }
    
    authors {
        bigserial id PK
        uuid uuid UK
        varchar first_name
        varchar last_name
        varchar full_name "Auto-generated"
        text biography
        integer birth_year
        varchar nationality
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }
    
    book_authors {
        bigserial id PK
        bigint book_id FK
        bigint author_id FK
        integer author_order "1=primary 2=secondary"
        timestamptz created_at
    }
    
    genres {
        serial id PK
        varchar name UK "Fiction Science-Fiction etc"
        text description
        timestamptz created_at
    }
    
    members {
        bigserial id PK
        uuid uuid UK
        varchar member_id UK "LIB001 LIB002"
        varchar first_name
        varchar last_name
        varchar full_name "Auto-generated"
        email_address email UK "Validated email"
        phone_number phone "Validated phone"
        varchar address_line1
        varchar city
        varchar country
        member_status status "active|suspended|expired"
        date membership_start_date
        date membership_expiry_date
        integer max_books_allowed "Default=3"
        integer current_books_borrowed "Auto-computed"
        integer total_books_borrowed "Lifetime total"
        boolean has_overdue_books "Auto-computed"
        text notes
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }
    
    borrowing_transactions {
        bigserial id PK
        uuid uuid UK
        bigint member_id FK
        bigint book_copy_id FK
        bigint book_id FK
        transaction_status status "active|returned|overdue"
        timestamptz borrowed_at "Check-out timestamp"
        date due_date "Default=+14days"
        timestamptz returned_at "Check-in timestamp"
        integer days_overdue "0 if on-time"
        integer renewal_count "Number of renewals"
        text librarian_notes
        timestamptz created_at
        timestamptz updated_at
    }
```

---

## Simplified Relationship View

```mermaid
graph TB
    subgraph "Book Catalog"
        G[Genres<br/>12 pre-loaded]
        A[Authors]
        B[Books<br/>ISBN, Title, Description]
        BA[Book-Authors<br/>Junction Table]
        BC[Book Copies<br/>Physical Items]
    end
    
    subgraph "Members"
        M[Members<br/>Library Card Holders]
    end
    
    subgraph "Borrowing"
        BT[Borrowing Transactions<br/>Check-out/Returns]
    end
    
    subgraph "Audit"
        AL[Audit Logs<br/>Partitioned by Month]
    end
    
    G -->|belongs to| B
    A -->|many-to-many| BA
    B -->|many-to-many| BA
    B -->|has copies| BC
    M -->|borrows| BT
    BC -->|tracked in| BT
    B -->|tracked in| BT
    
    style G fill:#e1f5ff
    style A fill:#e1f5ff
    style B fill:#ffe1e1
    style BA fill:#f0f0f0
    style BC fill:#ffe1e1
    style M fill:#e1ffe1
    style BT fill:#fff4e1
    style AL fill:#f0f0f0
```

---

## Data Flow: Borrowing Process

```mermaid
sequenceDiagram
    participant L as Librarian
    participant M as Member
    participant BC as Book Copy
    participant BT as Borrowing Transaction
    participant B as Books Table
    
    L->>M: Check member eligibility
    activate M
    M-->>L: Status: active, Books: 2/3, No overdue
    deactivate M
    
    L->>BC: Check book copy availability
    activate BC
    BC-->>L: Status: available
    deactivate BC
    
    L->>BT: Create borrowing transaction
    activate BT
    Note over BT: Trigger: check_borrowing_eligibility()
    Note over BT: Auto-set due_date = today + 14 days
    BT->>BC: Update status = 'borrowed'
    BT->>BC: Increment total_borrows
    BT->>M: Increment current_books_borrowed
    BT->>M: Increment total_books_borrowed
    BT->>B: Decrement available_copies
    deactivate BT
    
    Note over L,B: ✅ Book checked out successfully
```

---

## Key Relationships Summary

| Parent Table | Child Table | Relationship | Description |
|--------------|-------------|--------------|-------------|
| **genres** | books | 1:Many | Each book belongs to one genre |
| **books** | book_copies | 1:Many | One book can have multiple physical copies |
| **books** | book_authors | 1:Many | Books can have multiple authors |
| **authors** | book_authors | 1:Many | Authors can write multiple books |
| **book_copies** | borrowing_transactions | 1:Many | Track each copy's borrowing history |
| **members** | borrowing_transactions | 1:Many | Members can have multiple borrows |
| **books** | borrowing_transactions | 1:Many | Track which books are borrowed (denormalized) |

---

## Business Rules Enforced

### 🔒 Constraints (Database Level)
1. **Max 3 books per member** - Enforced by trigger
2. **No borrowing with overdue books** - Enforced by trigger
3. **Copy must be available** - Enforced by trigger
4. **14-day default loan period** - Auto-set by trigger
5. **ISBN uniqueness** - Unique constraint
6. **Copy number uniqueness** - Unique across entire library
7. **Email validation** - Custom domain type
8. **Phone validation** - Custom domain type

### ⚙️ Automatic Updates (Triggers)
1. **Book.total_copies** - Updated when copies added/removed
2. **Book.available_copies** - Updated when copy status changes
3. **Member.current_books_borrowed** - Updated on borrow/return
4. **Member.has_overdue_books** - Updated daily
5. **BookCopy.status** - Auto-changed on borrow/return
6. **updated_at timestamps** - Auto-updated on all tables

---

## Statistics & Reporting Views

### Materialized Views (Refresh Daily)
1. **popular_books_stats** - Top books by week/month/year
2. **genre_popularity_stats** - Genre borrowing trends
3. **member_activity_stats** - Daily activity metrics

### Real-time Views
1. **overdue_books_current** - Active overdue books with member contact
2. **books_availability** - Book catalog with availability and authors
3. **member_borrowing_summary** - Member status and limits

---

## Database Statistics

| Entity | Count | Notes |
|--------|-------|-------|
| **Tables** | 9 | Core + audit + migrations |
| **Views** | 3 | Real-time queries |
| **Materialized Views** | 3 | Pre-computed statistics |
| **Functions** | 7 | Business logic helpers |
| **Triggers** | 11 | Automatic data management |
| **Indexes** | 27+ | Performance optimization |
| **Custom Types** | 3 | ENUMs for status fields |
| **Custom Domains** | 3 | Email, phone, ISBN validation |

---

## Color Legend for Diagrams

- 🔵 **Blue** - Reference/Lookup tables (genres, authors)
- 🔴 **Red** - Core business entities (books, book_copies)
- 🟢 **Green** - User entities (members)
- 🟡 **Yellow** - Transactional data (borrowing_transactions)
- ⚪ **Gray** - Junction/Support tables (book_authors, audit_logs)
