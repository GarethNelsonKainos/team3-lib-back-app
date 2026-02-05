import { Author } from './Author.js';
import { Genre } from './Genre.js';

export interface Book {
  book_id: number;
  title: string;
  isbn: string;
  publication_year: number | null;
  description: string | null;
}

export interface BookWithDetails extends Book {
  authors: Author[];
  genres: Genre[];
}

export interface CreateBookDto {
  title: string;
  isbn: string;
  publication_year?: number | null;
  description?: string | null;
  author_ids?: number[];
  genre_ids?: number[];
}

export interface UpdateBookDto {
  title?: string;
  isbn?: string;
  publication_year?: number | null;
  description?: string | null;
  author_ids?: number[];
  genre_ids?: number[];
}