import { Request, Response, Router } from 'express';
import { AuthorService } from '../services/AuthorService.js';

export class AuthorController {
  public router: Router;
  private authorService: AuthorService;

  constructor() {
    this.router = Router();
    this.authorService = new AuthorService();
    this.initializeRoutes();
  }

  private initializeRoutes(): void {
    this.router.get('/', this.getAllAuthors.bind(this));
    this.router.get('/:id', this.getAuthorById.bind(this));
    this.router.post('/', this.createAuthor.bind(this));
    this.router.put('/:id', this.updateAuthor.bind(this));
    this.router.delete('/:id', this.deleteAuthor.bind(this));
  }

  private async getAllAuthors(req: Request, res: Response): Promise<void> {
    try {
      const authors = await this.authorService.getAllAuthors();
      res.json(authors);
    } catch (error) {
      res.status(500).json();
    }
  }

  private async getAuthorById(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id as string);
      const author = await this.authorService.getAuthorById(id);
      
      if (!author) {
        res.status(404).json();
        return;
      }
      
      res.json(author);
    } catch (error) {
      res.status(500).json();
    }
  }

  private async createAuthor(req: Request, res: Response): Promise<void> {
    try {
      const author = await this.authorService.createAuthor(req.body);
      res.status(201).json(author);
    } catch (error) {
      res.status(500).json();
    }
  }

  private async updateAuthor(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id as string);
      const author = await this.authorService.updateAuthor(id, req.body);
      
      if (!author) {
        res.status(404).json();
        return;
      }
      
      res.json(author);
    } catch (error) {
      res.status(500).json();
    }
  }

  private async deleteAuthor(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id as string);
      const deleted = await this.authorService.deleteAuthor(id);
      
      if (!deleted) {
        res.status(404).json();
        return;
      }
      
      res.status(204).send();
    } catch (error) {
      res.status(500).json();
    }
  }
}