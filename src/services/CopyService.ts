import { CopyDao } from '../dao/CopyDao.js';
import { Copy, CreateCopyDto, UpdateCopyDto } from '../models/Copy.js';

export class CopyService {
  private copyDao: CopyDao;

  constructor() {
    this.copyDao = new CopyDao();
  }

  async getAllCopies(): Promise<Copy[]> {
    return this.copyDao.findAll();
  }

  async getCopyById(id: number): Promise<Copy | null> {
    return this.copyDao.findById(id);
  }

  async createCopy(data: CreateCopyDto): Promise<Copy> {
    return this.copyDao.create(data);
  }

  async updateCopy(id: number, data: UpdateCopyDto): Promise<Copy | null> {
    return this.copyDao.update(id, data);
  }

  async deleteCopy(id: number): Promise<boolean> {
    return this.copyDao.delete(id);
  }
}
