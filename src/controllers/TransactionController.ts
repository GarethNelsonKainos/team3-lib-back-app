import { Request, Response, Router } from 'express';
import { TransactionService } from '../services/TransactionService.js';

export class TransactionController {
  public router: Router;
  private transactionService: TransactionService;

  constructor() {
    this.router = Router();
    this.transactionService = new TransactionService();
    this.initializeRoutes();
  }

  private initializeRoutes(): void {
    this.router.get('/', this.getAllTransactions.bind(this));
    this.router.get('/:id', this.getTransactionById.bind(this));
    this.router.post('/', this.createTransaction.bind(this));
    this.router.put('/:id', this.updateTransaction.bind(this));
    this.router.delete('/:id', this.deleteTransaction.bind(this));
  }

  private async getAllTransactions(req: Request, res: Response): Promise<void> {
    try {
      const transactions = await this.transactionService.getAllTransactions();
      res.json(transactions);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch transactions' });
    }
  }

  private async getTransactionById(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const transaction = await this.transactionService.getTransactionById(id);
      
      if (!transaction) {
        res.status(404).json({ error: 'Transaction not found' });
        return;
      }
      
      res.json(transaction);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch transaction' });
    }
  }

  private async createTransaction(req: Request, res: Response): Promise<void> {
    try {
      const transaction = await this.transactionService.createTransaction(req.body);
      res.status(201).json(transaction);
    } catch (error) {
      res.status(500).json({ error: 'Failed to create transaction' });
    }
  }

  private async updateTransaction(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const transaction = await this.transactionService.updateTransaction(id, req.body);
      
      if (!transaction) {
        res.status(404).json({ error: 'Transaction not found' });
        return;
      }
      
      res.json(transaction);
    } catch (error) {
      res.status(500).json({ error: 'Failed to update transaction' });
    }
  }

  private async deleteTransaction(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const deleted = await this.transactionService.deleteTransaction(id);
      
      if (!deleted) {
        res.status(404).json({ error: 'Transaction not found' });
        return;
      }
      
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete transaction' });
    }
  }
}