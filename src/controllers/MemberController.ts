import { Request, Response, Router } from 'express';
import { MemberService } from '../services/MemberService.js';

export class MemberController {
  public router: Router;
  private memberService: MemberService;

  constructor() {
    this.router = Router();
    this.memberService = new MemberService();
    this.initializeRoutes();
  }

  private initializeRoutes(): void {
    this.router.get('/', this.getAllMembers.bind(this));
    this.router.get('/:id', this.getMemberById.bind(this));
    this.router.post('/', this.createMember.bind(this));
    this.router.put('/:id', this.updateMember.bind(this));
    this.router.delete('/:id', this.deleteMember.bind(this));
  }

  private async getAllMembers(req: Request, res: Response): Promise<void> {
    try {
      const members = await this.memberService.getAllMembers();
      res.json(members);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch members' });
    }
  }

  private async getMemberById(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const member = await this.memberService.getMemberById(id);
      
      if (!member) {
        res.status(404).json({ error: 'Member not found' });
        return;
      }
      
      res.json(member);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch member' });
    }
  }

  private async createMember(req: Request, res: Response): Promise<void> {
    try {
      const member = await this.memberService.createMember(req.body);
      res.status(201).json(member);
    } catch (error) {
      res.status(500).json({ error: 'Failed to create member' });
    }
  }

  private async updateMember(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const member = await this.memberService.updateMember(id, req.body);
      
      if (!member) {
        res.status(404).json({ error: 'Member not found' });
        return;
      }
      
      res.json(member);
    } catch (error) {
      res.status(500).json({ error: 'Failed to update member' });
    }
  }

  private async deleteMember(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id);
      const deleted = await this.memberService.deleteMember(id);
      
      if (!deleted) {
        res.status(404).json({ error: 'Member not found' });
        return;
      }
      
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete member' });
    }
  }
}
