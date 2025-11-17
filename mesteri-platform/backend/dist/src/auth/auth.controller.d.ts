import { AuthService } from './auth.service';
import { CreateUserDto } from '../users/dto/create-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    login(loginUserDto: LoginUserDto): Promise<void>;
    register(createUserDto: CreateUserDto): Promise<void>;
    getProfile(req: any): Promise<void>;
    logout(): Promise<{
        message: string;
    }>;
    forgotPassword(forgotPasswordDto: ForgotPasswordDto): Promise<void>;
    resetPassword(resetPasswordDto: ResetPasswordDto): Promise<void>;
    refreshToken(refreshTokenDto: RefreshTokenDto): Promise<void>;
}
