export interface Genre {
  genre_id: number;
  genre_name: string;
}

export interface CreateGenreDto {
  genre_name: string;
}

export interface UpdateGenreDto {
  genre_name?: string;
}