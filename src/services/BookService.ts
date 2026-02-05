import { BookDao } from '../dao/BookDao.js';
import { BookWithDetails, CreateBookDto, UpdateBookDto } from '../models/Book.js';

export class BookService {
  private bookDao: BookDao;

  constructor() {
    this.bookDao = new BookDao();
  }

  async getAllBooks(): Promise<BookWithDetails[]> {
    return this.bookDao.findAll();
  }

  async getBookById(id: number): Promise<BookWithDetails | null> {
    return this.bookDao.findById(id);
  }

  async createBook(data: CreateBookDto): Promise<BookWithDetails> {
    return this.bookDao.create(data);
  }

  async updateBook(id: number, data: UpdateBookDto): Promise<BookWithDetails | null> {
    return this.bookDao.update(id, data);
  }

  async deleteBook(id: number): Promise<boolean> {
    return this.bookDao.delete(id);
  }
}