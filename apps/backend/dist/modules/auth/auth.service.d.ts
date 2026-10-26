import { JwtService } from '@nestjs/jwt';
export declare class AuthService {
    private readonly jwtService;
    constructor(jwtService: JwtService);
    hashPassword(password: string): Promise<string>;
    validatePassword(password: string, hash: string): Promise<boolean>;
    generateJwt(userId: string, role: string): Promise<{
        access_token: string;
        expires_in: string;
    }>;
}
