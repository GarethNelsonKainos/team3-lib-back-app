import { Request, Response, Router } from 'express';
import { BookService } from '../services/BookService.js';

export class BookController {
  public router: Router;
  private bookService: BookService;

  constructor() {
    this.router = Router();
    this.bookService = new BookService();
    this.initializeRoutes();
  }

  private initializeRoutes(): void {
    this.router.get('/', this.getAllBooks.bind(this));
    this.router.get('/:id', this.getBookById.bind(this));
    this.router.post('/', this.createBook.bind(this));
    this.router.put('/:id', this.updateBook.bind(this));
    this.router.delete('/:id', this.deleteBook.bind(this));
  }

  private async getAllBooks(req: Request, res: Response): Promise<void> {
    try {
      const books = await this.bookService.getAllBooks();
      res.json(books);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch books' });
    }
  }

  private async getBookById(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const book = await this.bookService.getBookById(id);
      
      if (!book) {
        res.status(404).json({ error: 'Book not found' });
        return;
      }
      
      res.json(book);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch book' });
    }
  }

  private async createBook(req: Request, res: Response): Promise<void> {
    try {
      const book = await this.bookService.createBook(req.body);
      res.status(201).json(book);
    } catch (error) {
      res.status(500).json({ error: 'Failed to create book' });
    }
  }

  private async updateBook(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const book = await this.bookService.updateBook(id, req.body);
      
      if (!book) {
        res.status(404).json({ error: 'Book not found' });
        return;
      }
      
      res.json(book);
    } catch (error) {
      res.status(500).json({ error: 'Failed to update book' });
    }
  }

  private async deleteBook(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const deleted = await this.bookService.deleteBook(id);
      
      if (!deleted) {
        res.status(404).json({ error: 'Book not found' });
        return;
      }
      
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete book' });
    }
  }
}
