import { db } from '../config/database.js';
import { Author, CreateAuthorDto, UpdateAuthorDto } from '../models/Author.js';

export class AuthorDao {
  async findAll(): Promise<Author[]> {
    return db.manyOrNone<Author>('SELECT * FROM authors ORDER BY author_id');
  }

  async findById(id: number): Promise<Author | null> {
    return db.oneOrNone<Author>('SELECT * FROM authors WHERE author_id = $1', [id]);
  }

  async create(data: CreateAuthorDto): Promise<Author> {
    return db.one<Author>(
      'INSERT INTO authors (author_name) VALUES ($1) RETURNING *',
      [data.author_name]
    );
  }

  async update(id: number, data: UpdateAuthorDto): Promise<Author | null> {
    return db.oneOrNone<Author>(
      'UPDATE authors SET author_name = $1 WHERE author_id = $2 RETURNING *',
      [data.author_name, id]
    );
  }

  async delete(id: number): Promise<boolean> {
    const result = await db.result('DELETE FROM authors WHERE author_id = $1', [id]);
    return result.rowCount > 0;
  }
}