export interface Member {
  member_id: number;
  full_name: string;
  contact_information: string | null;
  address_line_1: string | null;
  address_line_2: string | null;
  city: string;
  post_code: string;
  join_date: Date;
  expiry_date: Date;
}

export interface CreateMemberDto {
  full_name: string;
  contact_information?: string | null;
  address_line_1?: string | null;
  address_line_2?: string | null;
  city: string;
  post_code: string;
  join_date: Date;
  expiry_date: Date;
}

export interface UpdateMemberDto {
  full_name?: string;
  contact_information?: string | null;
  address_line_1?: string | null;
  address_line_2?: string | null;
  city?: string;
  post_code?: string;
  join_date?: Date;
  expiry_date?: Date;
}