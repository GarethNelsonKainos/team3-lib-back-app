import { db } from '../config/database.js';
import { Book, BookWithDetails, CreateBookDto, UpdateBookDto } from '../models/Book.js';
import { Author } from '../models/Author.js';
import { Genre } from '../models/Genre.js';
import { IDatabase, ITask } from 'pg-promise';

export class BookDao {
  async findAll(): Promise<BookWithDetails[]> {
    const books = await db.manyOrNone<Book>('SELECT * FROM books ORDER BY book_id');
    
    const booksWithDetails: BookWithDetails[] = [];
    for (const book of books) {
      const authors = await this.getBookAuthors(book.book_id);
      const genres = await this.getBookGenres(book.book_id);
      booksWithDetails.push({ ...book, authors, genres });
    }
    
    return booksWithDetails;
  }

  async findById(id: number): Promise<BookWithDetails | null> {
    const book = await db.oneOrNone<Book>('SELECT * FROM books WHERE book_id = $1', [id]);
    
    if (!book) {
      return null;
    }
    
    const authors = await this.getBookAuthors(id);
    const genres = await this.getBookGenres(id);
    
    return { ...book, authors, genres };
  }

  async create(data: CreateBookDto): Promise<BookWithDetails> {
    return db.tx(async t => {
      const book = await t.one<Book>(
        'INSERT INTO books (title, isbn, publication_year, description) VALUES ($1, $2, $3, $4) RETURNING *',
        [data.title, data.isbn, data.publication_year, data.description]
      );

      if (data.author_ids && data.author_ids.length > 0) {
        await this.setBookAuthors(book.book_id, data.author_ids, t);
      }

      if (data.genre_ids && data.genre_ids.length > 0) {
        await this.setBookGenres(book.book_id, data.genre_ids, t);
      }

      const authors = await this.getBookAuthors(book.book_id, t);
      const genres = await this.getBookGenres(book.book_id, t);

      return { ...book, authors, genres };
    });
  }

  async update(id: number, data: UpdateBookDto): Promise<BookWithDetails | null> {
    return db.tx(async t => {
      const updates: string[] = [];
      const values: any[] = [];
      let paramCount = 1;

      if (data.title !== undefined) {
        updates.push(`title = $${paramCount++}`);
        values.push(data.title);
      }
      if (data.isbn !== undefined) {
        updates.push(`isbn = $${paramCount++}`);
        values.push(data.isbn);
      }
      if (data.publication_year !== undefined) {
        updates.push(`publication_year = $${paramCount++}`);
        values.push(data.publication_year);
      }
      if (data.description !== undefined) {
        updates.push(`description = $${paramCount++}`);
        values.push(data.description);
      }

      if (updates.length > 0) {
        values.push(id);
        const query = `UPDATE books SET ${updates.join(', ')} WHERE book_id = $${paramCount} RETURNING *`;
        await t.oneOrNone<Book>(query, values);
      }

      if (data.author_ids !== undefined) {
        await t.none('DELETE FROM book_authors WHERE book_id = $1', [id]);
        if (data.author_ids.length > 0) {
          await this.setBookAuthors(id, data.author_ids, t);
        }
      }

      if (data.genre_ids !== undefined) {
        await t.none('DELETE FROM book_genres WHERE book_id = $1', [id]);
        if (data.genre_ids.length > 0) {
          await this.setBookGenres(id, data.genre_ids, t);
        }
      }

      const book = await t.oneOrNone<Book>('SELECT * FROM books WHERE book_id = $1', [id]);
      if (!book) {
        return null;
      }

      const authors = await this.getBookAuthors(id, t);
      const genres = await this.getBookGenres(id, t);

      return { ...book, authors, genres };
    });
  }

  async delete(id: number): Promise<boolean> {
    return db.tx(async t => {
      await t.none('DELETE FROM book_authors WHERE book_id = $1', [id]);
      await t.none('DELETE FROM book_genres WHERE book_id = $1', [id]);
      const result = await t.result('DELETE FROM books WHERE book_id = $1', [id]);
      return result.rowCount > 0;
    });
  }

  private async getBookAuthors(bookId: number, connection: IDatabase<any> | ITask<any> = db): Promise<Author[]> {
    return connection.manyOrNone<Author>(
      `SELECT a.* FROM authors a
       INNER JOIN book_authors ba ON a.author_id = ba.author_id
       WHERE ba.book_id = $1
       ORDER BY a.author_id`,
      [bookId]
    );
  }

  private async getBookGenres(bookId: number, connection: IDatabase<any> | ITask<any> = db): Promise<Genre[]> {
    return connection.manyOrNone<Genre>(
      `SELECT g.* FROM genres g
       INNER JOIN book_genres bg ON g.genre_id = bg.genre_id
       WHERE bg.book_id = $1
       ORDER BY g.genre_id`,
      [bookId]
    );
  }

  private async setBookAuthors(bookId: number, authorIds: number[], connection: IDatabase<any> | ITask<any> = db): Promise<void> {
    const values = authorIds.map(authorId => `(${bookId}, ${authorId})`).join(',');
    await connection.none(`INSERT INTO book_authors (book_id, author_id) VALUES ${values}`);
  }

  private async setBookGenres(bookId: number, genreIds: number[], connection: IDatabase<any> | ITask<any> = db): Promise<void> {
    const values = genreIds.map(genreId => `(${bookId}, ${genreId})`).join(',');
    await connection.none(`INSERT INTO book_genres (book_id, genre_id) VALUES ${values}`);
  }
}