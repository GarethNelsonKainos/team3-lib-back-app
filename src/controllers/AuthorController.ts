import { Request, Response, Router } from 'express';
import { AuthorService } from '../services/AuthorService.js';

export class AuthorController {
  public router: Router;
  private authorService: AuthorService;

  constructor(authorService: AuthorService = new AuthorService()) {
    this.router = Router();
    this.authorService = authorService;
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
    } catch (error: Error | any) {
      res.status(500).json({
        error: error.message || 'An error occurred while fetching authors.',
      });
    }
  }

  private async getAuthorById(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id as string);
        if (isNaN(id) || id < 1) {
        res.status(400).json({ error: 'Invalid author ID' });
        return;
      }
      const author = await this.authorService.getAuthorById(id);
      
      if (!author) {
        res.status(404).json({
            error: 'Author not found.',
        });
        return;
      }
      
      res.json(author);
    } catch (error: Error | any) {
      res.status(500).json({
        error: error.message || 'An error occurred while fetching the author.',
      });
    }
  }

  private async createAuthor(req: Request, res: Response): Promise<void> {
  try {
    const { author_name } = req.body;
    if (!author_name) {
      res.status(400).json({ error: 'Author name is required' });
      return;
    }
    if (typeof author_name !== 'string') {
      res.status(400).json({ error: 'Author name must be a string' });
      return;
    }
    if (author_name.trim() === '') {
      res.status(400).json({ error: 'Author name cannot be empty' });
      return;
    }
    if (author_name.length > 255 || author_name.length < 1) {
      res.status(400).json({ error: 'Author name must be between 1 and 255 characters' });
      return;
    }
    
    const author = await this.authorService.createAuthor({ author_name });
    res.status(201).json(author);
  } catch (error: Error | any) {
    res.status(500).json({ 
      error: error.message || 'Failed to create author',
    });
  }
}

  private async updateAuthor(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id as string);
        if (isNaN(id) || id < 1) {
        res.status(400).json({ error: 'Invalid author ID' });
        return;
      }
      const author = await this.authorService.updateAuthor(id, req.body);
      
      if (!author) {
        res.status(404).json({
          error: 'Author not found.',
        });
        return;
      }
      
      res.json(author);
    } catch (error: Error | any) {
      res.status(500).json({
        error: error.message || 'An error occurred while updating the author.',
      });
    }
  }

  private async deleteAuthor(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id as string);
        if (isNaN(id) || id < 1) {
        res.status(400).json({ error: 'Invalid author ID' });
        return;
      }
      const deleted = await this.authorService.deleteAuthor(id);
      
      if (!deleted) {
        res.status(404).json({
          error: 'Author not found.',
        });
        return;
      }
      
      res.status(204).send();
    } catch (error: Error | any) {
      res.status(500).json({
        error: error.message || 'An error occurred while deleting the author.',
      });
    }
  }
}