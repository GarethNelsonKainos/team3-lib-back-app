import { db } from '../config/database.js';
import { Copy, CreateCopyDto, UpdateCopyDto } from '../models/Copy.js';

export class CopyDao {
  async findAll(): Promise<Copy[]> {
    return db.manyOrNone<Copy>('SELECT * FROM copies ORDER BY copy_id');
  }

  async findById(id: number): Promise<Copy | null> {
    return db.oneOrNone<Copy>('SELECT * FROM copies WHERE copy_id = $1', [id]);
  }

  async create(data: CreateCopyDto): Promise<Copy> {
    return db.one<Copy>(
      'INSERT INTO copies (copy_identifier, book_id, status) VALUES ($1, $2, $3) RETURNING *',
      [data.copy_identifier, data.book_id, data.status]
    );
  }

  async update(id: number, data: UpdateCopyDto): Promise<Copy | null> {
    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (data.copy_identifier !== undefined) {
      updates.push(`copy_identifier = $${paramCount++}`);
      values.push(data.copy_identifier);
    }
    if (data.book_id !== undefined) {
      updates.push(`book_id = $${paramCount++}`);
      values.push(data.book_id);
    }
    if (data.status !== undefined) {
      updates.push(`status = $${paramCount++}`);
      values.push(data.status);
    }

    if (updates.length === 0) {
      return this.findById(id);
    }

    values.push(id);
    const query = `UPDATE copies SET ${updates.join(', ')} WHERE copy_id = $${paramCount} RETURNING *`;
    
    return db.oneOrNone<Copy>(query, values);
  }

  async delete(id: number): Promise<boolean> {
    const result = await db.result('DELETE FROM copies WHERE copy_id = $1', [id]);
    return result.rowCount > 0;
  }
}
