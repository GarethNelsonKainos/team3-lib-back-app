export interface Transaction {
  transaction_id: number;
  member_id: number;
  copy_id: number;
  checkout_timestamp: Date;
  due_date: Date;
  return_timestamp: Date | null;
}

export interface CreateTransactionDto {
  member_id: number;
  copy_id: number;
  checkout_timestamp: Date;
  due_date: Date;
  return_timestamp?: Date | null;
}

export interface UpdateTransactionDto {
  member_id?: number;
  copy_id?: number;
  checkout_timestamp?: Date;
  due_date?: Date;
  return_timestamp?: Date | null;
}
