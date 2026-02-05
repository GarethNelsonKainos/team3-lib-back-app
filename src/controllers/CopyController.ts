import { Request, Response, Router } from 'express';
import { CopyService } from '../services/CopyService.js';

export class CopyController {
  public router: Router;
  private copyService: CopyService;

  constructor() {
    this.router = Router();
    this.copyService = new CopyService();
    this.initializeRoutes();
  }

  private initializeRoutes(): void {
    this.router.get('/', this.getAllCopies.bind(this));
    this.router.get('/:id', this.getCopyById.bind(this));
    this.router.post('/', this.createCopy.bind(this));
    this.router.put('/:id', this.updateCopy.bind(this));
    this.router.delete('/:id', this.deleteCopy.bind(this));
  }

  private async getAllCopies(req: Request, res: Response): Promise<void> {
    try {
      const copies = await this.copyService.getAllCopies();
      res.json(copies);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch copies' });
    }
  }

  private async getCopyById(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const copy = await this.copyService.getCopyById(id);
      
      if (!copy) {
        res.status(404).json({ error: 'Copy not found' });
        return;
      }
      
      res.json(copy);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch copy' });
    }
  }

  private async createCopy(req: Request, res: Response): Promise<void> {
    try {
      const copy = await this.copyService.createCopy(req.body);
      res.status(201).json(copy);
    } catch (error) {
      res.status(500).json({ error: 'Failed to create copy' });
    }
  }

  private async updateCopy(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const copy = await this.copyService.updateCopy(id, req.body);
      
      if (!copy) {
        res.status(404).json({ error: 'Copy not found' });
        return;
      }
      
      res.json(copy);
    } catch (error) {
      res.status(500).json({ error: 'Failed to update copy' });
    }
  }

  private async deleteCopy(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const deleted = await this.copyService.deleteCopy(id);
      
      if (!deleted) {
        res.status(404).json({ error: 'Copy not found' });
        return;
      }
      
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete copy' });
    }
  }
}
