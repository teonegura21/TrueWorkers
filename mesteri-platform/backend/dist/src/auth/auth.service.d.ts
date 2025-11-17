import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from '../users/dto/create-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
export declare class AuthService {
    private prisma;
    constructor(prisma: PrismaService);
    validateUser(email: string, password: string): Promise<any>;
    login(loginUserDto: LoginUserDto): Promise<void>;
    register(createUserDto: CreateUserDto): Promise<void>;
    getProfile(userId: string): Promise<void>;
    forgotPassword(forgotPasswordDto: {
        email: string;
    }): Promise<void>;
    resetPassword(resetPasswordDto: {
        token: string;
        newPassword: string;
    }): Promise<void>;
    refreshToken(refreshTokenDto: {
        refreshToken: string;
    }): Promise<void>;
}
