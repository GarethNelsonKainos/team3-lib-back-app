import { db } from '../config/database.js';
import { Member, CreateMemberDto, UpdateMemberDto } from '../models/Member.js';

export class MemberDao {
  async findAll(): Promise<Member[]> {
    return db.manyOrNone<Member>('SELECT * FROM members ORDER BY member_id');
  }

  async findById(id: number): Promise<Member | null> {
    return db.oneOrNone<Member>('SELECT * FROM members WHERE member_id = $1', [id]);
  }

  async create(data: CreateMemberDto): Promise<Member> {
    return db.one<Member>(
      `INSERT INTO members (full_name, contact_information, address_line_1, address_line_2, city, post_code, join_date, expiry_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [
        data.full_name,
        data.contact_information,
        data.address_line_1,
        data.address_line_2,
        data.city,
        data.post_code,
        data.join_date,
        data.expiry_date,
      ]
    );
  }

  async update(id: number, data: UpdateMemberDto): Promise<Member | null> {
    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (data.full_name !== undefined) {
      updates.push(`full_name = $${paramCount++}`);
      values.push(data.full_name);
    }
    if (data.contact_information !== undefined) {
      updates.push(`contact_information = $${paramCount++}`);
      values.push(data.contact_information);
    }
    if (data.address_line_1 !== undefined) {
      updates.push(`address_line_1 = $${paramCount++}`);
      values.push(data.address_line_1);
    }
    if (data.address_line_2 !== undefined) {
      updates.push(`address_line_2 = $${paramCount++}`);
      values.push(data.address_line_2);
    }
    if (data.city !== undefined) {
      updates.push(`city = $${paramCount++}`);
      values.push(data.city);
    }
    if (data.post_code !== undefined) {
      updates.push(`post_code = $${paramCount++}`);
      values.push(data.post_code);
    }
    if (data.join_date !== undefined) {
      updates.push(`join_date = $${paramCount++}`);
      values.push(data.join_date);
    }
    if (data.expiry_date !== undefined) {
      updates.push(`expiry_date = $${paramCount++}`);
      values.push(data.expiry_date);
    }

    if (updates.length === 0) {
      return this.findById(id);
    }

    values.push(id);
    const query = `UPDATE members SET ${updates.join(', ')} WHERE member_id = $${paramCount} RETURNING *`;
    
    return db.oneOrNone<Member>(query, values);
  }

  async delete(id: number): Promise<boolean> {
    const result = await db.result('DELETE FROM members WHERE member_id = $1', [id]);
    return result.rowCount > 0;
  }
}
