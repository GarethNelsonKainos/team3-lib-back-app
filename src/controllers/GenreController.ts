import { Request, Response, Router } from 'express';
import { GenreService } from '../services/GenreService.js';

export class GenreController {
  public router: Router;
  private genreService: GenreService;

  constructor() {
    this.router = Router();
    this.genreService = new GenreService();
    this.initializeRoutes();
  }

  private initializeRoutes(): void {
    this.router.get('/', this.getAllGenres.bind(this));
    this.router.get('/:id', this.getGenreById.bind(this));
    this.router.post('/', this.createGenre.bind(this));
    this.router.put('/:id', this.updateGenre.bind(this));
    this.router.delete('/:id', this.deleteGenre.bind(this));
  }

  private async getAllGenres(req: Request, res: Response): Promise<void> {
    try {
      const genres = await this.genreService.getAllGenres();
      res.json(genres);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch genres' });
    }
  }

  private async getGenreById(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const genre = await this.genreService.getGenreById(id);
      
      if (!genre) {
        res.status(404).json({ error: 'Genre not found' });
        return;
      }
      
      res.json(genre);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch genre' });
    }
  }

  private async createGenre(req: Request, res: Response): Promise<void> {
    try {
      const genre = await this.genreService.createGenre(req.body);
      res.status(201).json(genre);
    } catch (error) {
      res.status(500).json({ error: 'Failed to create genre' });
    }
  }

  private async updateGenre(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const genre = await this.genreService.updateGenre(id, req.body);
      
      if (!genre) {
        res.status(404).json({ error: 'Genre not found' });
        return;
      }
      
      res.json(genre);
    } catch (error) {
      res.status(500).json({ error: 'Failed to update genre' });
    }
  }

  private async deleteGenre(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const deleted = await this.genreService.deleteGenre(id);
      
      if (!deleted) {
        res.status(404).json({ error: 'Genre not found' });
        return;
      }
      
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete genre' });
    }
  }
}