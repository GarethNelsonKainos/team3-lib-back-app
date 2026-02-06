import { TransactionDao } from '../dao/TransactionDao.js';
import { Transaction, CreateTransactionDto, UpdateTransactionDto } from '../models/Transaction.js';

export class TransactionService {
  private transactionDao: TransactionDao;

  constructor() {
    this.transactionDao = new TransactionDao();
  }

  async getAllTransactions(): Promise<Transaction[]> {
    return this.transactionDao.findAll();
  }

  async getTransactionById(id: number): Promise<Transaction | null> {
    return this.transactionDao.findById(id);
  }

  async createTransaction(data: CreateTransactionDto): Promise<Transaction> {
    // BUSINESS RULE: Check maximum 3 books per member
    const activeBooks = await this.transactionDao.findActiveTransactionsByMember(data.member_id);
    
    if (activeBooks.length >= 3) {
      throw new Error(`Member cannot borrow more than 3 books. Currently has ${activeBooks.length} active checkout(s).`);
    }
    
    return this.transactionDao.create(data);
  }

  async updateTransaction(id: number, data: UpdateTransactionDto): Promise<Transaction | null> {
    return this.transactionDao.update(id, data);
  }

  async deleteTransaction(id: number): Promise<boolean> {
    return this.transactionDao.delete(id);
  }
}
