import {
  Injectable,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from '../users/dto/create-user.dto';
import { LoginUserDto } from './dto/login-user.dto';

/**
 * Legacy Authentication Service - DEPRECATED
 * 
 * This service has been replaced by Firebase Authentication.
 * All methods now return deprecation warnings and redirect users to Firebase Auth.
 * 
 * For new authentication implementations:
 * 1. Use Firebase SDK on frontend for user registration/login
 * 2. Send Firebase ID tokens to backend endpoints
 * 3. Backend validates tokens via FirebaseAuthGuard
 * 
 * @deprecated Use Firebase Authentication instead
 */
@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
  ) {}

  /**
   * @deprecated Use Firebase Authentication instead
   */
  async validateUser(email: string, password: string): Promise<any> {
    throw new BadRequestException({
      error: 'DEPRECATED_ENDPOINT',
      message: 'Legacy authentication is deprecated. Please use Firebase Authentication.',
      migration: {
        frontend: 'Use Firebase SDK: firebase.auth().signInWithEmailAndPassword()',
        backend: 'Send Firebase ID token to protected endpoints with Authorization: Bearer <firebase-token>'
      }
    });
  }

  /**
   * @deprecated Use Firebase Authentication instead
   */
  async login(loginUserDto: LoginUserDto) {
    throw new BadRequestException({
      error: 'DEPRECATED_ENDPOINT',
      message: 'Legacy login is deprecated. Please use Firebase Authentication.',
      migration: {
        frontend: 'Use Firebase SDK: firebase.auth().signInWithEmailAndPassword()',
        backend: 'Send Firebase ID token to protected endpoints'
      }
    });
  }

  /**
   * @deprecated Use Firebase Authentication instead
   */
  async register(createUserDto: CreateUserDto) {
    throw new BadRequestException({
      error: 'DEPRECATED_ENDPOINT',
      message: 'Legacy registration is deprecated. Please use Firebase Authentication.',
      migration: {
        frontend: 'Use Firebase SDK: firebase.auth().createUserWithEmailAndPassword()',
        backend: 'Firebase will automatically sync users via FirebaseService'
      }
    });
  }

  /**
   * @deprecated Use Firebase Authentication instead
   */
  async getProfile(userId: string) {
    throw new BadRequestException({
      error: 'DEPRECATED_ENDPOINT',
      message: 'Legacy profile endpoint is deprecated.',
      migration: {
        alternative: 'Use GET /api/users/profile with Firebase token authentication'
      }
    });
  }

  /**
   * @deprecated Use Firebase Authentication instead
   */
  async forgotPassword(forgotPasswordDto: { email: string }) {
    throw new BadRequestException({
      error: 'DEPRECATED_ENDPOINT',
      message: 'Legacy password reset is deprecated. Please use Firebase Authentication.',
      migration: {
        frontend: 'Use Firebase SDK: firebase.auth().sendPasswordResetEmail()',
        note: 'Firebase handles password reset flow automatically'
      }
    });
  }

  /**
   * @deprecated Use Firebase Authentication instead
   */
  async resetPassword(resetPasswordDto: { token: string; newPassword: string }) {
    throw new BadRequestException({
      error: 'DEPRECATED_ENDPOINT', 
      message: 'Legacy password reset is deprecated. Please use Firebase Authentication.',
      migration: {
        frontend: 'Use Firebase SDK password reset flow',
        note: 'Firebase handles password reset confirmation automatically'
      }
    });
  }

  /**
   * @deprecated Use Firebase Authentication instead
   */
  async refreshToken(refreshTokenDto: { refreshToken: string }) {
    throw new BadRequestException({
      error: 'DEPRECATED_ENDPOINT',
      message: 'Legacy token refresh is deprecated. Please use Firebase Authentication.',
      migration: {
        frontend: 'Firebase SDK handles token refresh automatically',
        note: 'No manual token refresh needed with Firebase'
      }
    });
  }
}
