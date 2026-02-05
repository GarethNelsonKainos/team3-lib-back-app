import { AuthorDao } from '../dao/AuthorDao.js';
import { Author, CreateAuthorDto, UpdateAuthorDto } from '../models/Author.js';

export class AuthorService {
  private authorDao: AuthorDao;

  constructor() {
    this.authorDao = new AuthorDao();
  }

  async getAllAuthors(): Promise<Author[]> {
    return this.authorDao.findAll();
  }

  async getAuthorById(id: number): Promise<Author | null> {
    return this.authorDao.findById(id);
  }

  async createAuthor(data: CreateAuthorDto): Promise<Author> {
    return this.authorDao.create(data);
  }

  async updateAuthor(id: number, data: UpdateAuthorDto): Promise<Author | null> {
    return this.authorDao.update(id, data);
  }

  async deleteAuthor(id: number): Promise<boolean> {
    return this.authorDao.delete(id);
  }
}
