export interface Author {
  author_id: number;
  author_name: string;
}

export interface CreateAuthorDto {
  author_name: string;
}

export interface UpdateAuthorDto {
  author_name?: string;
}