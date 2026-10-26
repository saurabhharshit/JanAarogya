// apps/backend/src/modules/auth/auth.service.ts
import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { RegisterDto, LoginDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(private readonly jwtService: JwtService) {}

  async hashPassword(password: string): Promise<string> {
    const saltRounds = parseInt(process.env.SALT_ROUNDS || '12', 10);
    return await bcrypt.hash(password, saltRounds);
  }

  async validatePassword(password: string, hash: string): Promise<boolean> {
    return await bcrypt.compare(password, hash);
  }

  async generateJwt(userId: string, role: string) {
    const payload = { sub: userId, role };
    return {
      access_token: this.jwtService.sign(payload),
      expires_in: process.env.JWT_EXPIRATION || '7d',
    };
  }
}