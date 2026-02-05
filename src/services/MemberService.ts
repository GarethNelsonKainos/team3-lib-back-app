import { MemberDao } from '../dao/MemberDao.js';
import { Member, CreateMemberDto, UpdateMemberDto } from '../models/Member.js';

export class MemberService {
  private memberDao: MemberDao;

  constructor() {
    this.memberDao = new MemberDao();
  }

  async getAllMembers(): Promise<Member[]> {
    return this.memberDao.findAll();
  }

  async getMemberById(id: number): Promise<Member | null> {
    return this.memberDao.findById(id);
  }

  async createMember(data: CreateMemberDto): Promise<Member> {
    return this.memberDao.create(data);
  }

  async updateMember(id: number, data: UpdateMemberDto): Promise<Member | null> {
    return this.memberDao.update(id, data);
  }

  async deleteMember(id: number): Promise<boolean> {
    return this.memberDao.delete(id);
  }
}
