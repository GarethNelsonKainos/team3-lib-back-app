export interface Copy {
  copy_id: number;
  copy_identifier: string;
  book_id: number;
  status: string;
}

export interface CreateCopyDto {
  copy_identifier: string;
  book_id: number;
  status: string;
}

export interface UpdateCopyDto {
  copy_identifier?: string;
  book_id?: number;
  status?: string;
}
