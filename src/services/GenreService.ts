import { GenreDao } from '../dao/GenreDao.js';
import { Genre, CreateGenreDto, UpdateGenreDto } from '../models/Genre.js';

export class GenreService {
  private genreDao: GenreDao;

  constructor() {
    this.genreDao = new GenreDao();
  }

  async getAllGenres(): Promise<Genre[]> {
    return this.genreDao.findAll();
  }

  async getGenreById(id: number): Promise<Genre | null> {
    return this.genreDao.findById(id);
  }

  async createGenre(data: CreateGenreDto): Promise<Genre> {
    return this.genreDao.create(data);
  }

  async updateGenre(id: number, data: UpdateGenreDto): Promise<Genre | null> {
    return this.genreDao.update(id, data);
  }

  async deleteGenre(id: number): Promise<boolean> {
    return this.genreDao.delete(id);
  }
}