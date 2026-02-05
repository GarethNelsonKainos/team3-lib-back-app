import { db } from '../config/database.js';
import { Transaction, CreateTransactionDto, UpdateTransactionDto } from '../models/Transaction.js';

export class TransactionDao {
  async findAll(): Promise<Transaction[]> {
    return db.manyOrNone<Transaction>('SELECT * FROM transactions ORDER BY transaction_id');
  }

  async findById(id: number): Promise<Transaction | null> {
    return db.oneOrNone<Transaction>('SELECT * FROM transactions WHERE transaction_id = $1', [id]);
  }

  async create(data: CreateTransactionDto): Promise<Transaction> {
    return db.one<Transaction>(
      'INSERT INTO transactions (member_id, copy_id, checkout_timestamp, due_date, return_timestamp) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [data.member_id, data.copy_id, data.checkout_timestamp, data.due_date, data.return_timestamp || null]
    );
  }

  async update(id: number, data: UpdateTransactionDto): Promise<Transaction | null> {
    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (data.member_id !== undefined) {
      updates.push(`member_id = $${paramCount++}`);
      values.push(data.member_id);
    }
    if (data.copy_id !== undefined) {
      updates.push(`copy_id = $${paramCount++}`);
      values.push(data.copy_id);
    }
    if (data.checkout_timestamp !== undefined) {
      updates.push(`checkout_timestamp = $${paramCount++}`);
      values.push(data.checkout_timestamp);
    }
    if (data.due_date !== undefined) {
      updates.push(`due_date = $${paramCount++}`);
      values.push(data.due_date);
    }
    if (data.return_timestamp !== undefined) {
      updates.push(`return_timestamp = $${paramCount++}`);
      values.push(data.return_timestamp);
    }

    if (updates.length === 0) {
      return this.findById(id);
    }

    values.push(id);
    const query = `UPDATE transactions SET ${updates.join(', ')} WHERE transaction_id = $${paramCount} RETURNING *`;
    
    return db.oneOrNone<Transaction>(query, values);
  }

  async delete(id: number): Promise<boolean> {
    const result = await db.result('DELETE FROM transactions WHERE transaction_id = $1', [id]);
    return result.rowCount > 0;
  }
}