import { db } from '../config/database.js';
import { Genre, CreateGenreDto, UpdateGenreDto } from '../models/Genre.js';

export class GenreDao {
  async findAll(): Promise<Genre[]> {
    return db.manyOrNone<Genre>('SELECT * FROM genres ORDER BY genre_id');
  }

  async findById(id: number): Promise<Genre | null> {
    return db.oneOrNone<Genre>('SELECT * FROM genres WHERE genre_id = $1', [id]);
  }

  async create(data: CreateGenreDto): Promise<Genre> {
    return db.one<Genre>(
      'INSERT INTO genres (genre_name) VALUES ($1) RETURNING *',
      [data.genre_name]
    );
  }

  async update(id: number, data: UpdateGenreDto): Promise<Genre | null> {
    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (data.genre_name !== undefined) {
      updates.push(`genre_name = $${paramCount++}`);
      values.push(data.genre_name);
    }

    if (updates.length === 0) {
      return this.findById(id);
    }

    values.push(id);
    const query = `UPDATE genres SET ${updates.join(', ')} WHERE genre_id = $${paramCount} RETURNING *`;
    
    return db.oneOrNone<Genre>(query, values);
  }

  async delete(id: number): Promise<boolean> {
    const result = await db.result('DELETE FROM genres WHERE genre_id = $1', [id]);
    return result.rowCount > 0;
  }
}
