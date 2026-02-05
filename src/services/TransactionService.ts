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
    return this.transactionDao.create(data);
  }

  async updateTransaction(id: number, data: UpdateTransactionDto): Promise<Transaction | null> {
    return this.transactionDao.update(id, data);
  }

  async deleteTransaction(id: number): Promise<boolean> {
    return this.transactionDao.delete(id);
  }
}