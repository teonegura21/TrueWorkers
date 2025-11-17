import { Controller, Post, Body, UseGuards, BadRequestException, InternalServerErrorException } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';
import { UserSyncService } from '../firebase/user-sync.service';
import { Public } from '../decorators/auth.decorators';

export interface SetRoleDto {
  uid: string;
  role: 'client' | 'craftsman';
  email?: string;
  name?: string;
}

/**
 * Firebase Auth Controller
 * 
 * Handles Firebase-specific authentication operations like
 * setting custom claims and user role management
 * 
 * @author Archyt - Principal Engineer
 * @version 1.0.0
 */
@Controller('firebase-auth')
export class FirebaseAuthController {
  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly userSyncService: UserSyncService,
  ) {}

  /**
   * Set custom claims for a user (assign role)
   * This endpoint is called by Flutter apps after user registration
   */
  @Public()
  @Post('set-role')
  async setUserRole(@Body() setRoleDto: SetRoleDto) {
    const { uid, role, email, name } = setRoleDto;

    try {
      // Set custom claims for the user
      await this.firebaseService.setCustomClaims(uid, role);

      // Create user profile in Firestore
      await this.firebaseService.createUserProfile(uid, {
        uid,
        email: email || '',
        name: name || '',
        role,
        roleValue: role === 'client' ? 0 : 1,
        isVerified: false,
        rating: 0.0,
        completedProjects: 0,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      return {
        success: true,
        message: `Role ${role} assigned successfully`,
        uid,
        role,
        roleValue: role === 'client' ? 0 : 1,
      };
    } catch (error) {
      throw new InternalServerErrorException(`Failed to set user role: ${error.message}`);
    }
  }

  /**
   * Get user profile with custom claims
   */
  @Public()
  @Post('get-user-claims')
  async getUserClaims(@Body() { uid }: { uid: string }) {
    try {
      const userRecord = await this.firebaseService.getUserByUid(uid);
      
      return {
        uid: userRecord.uid,
        email: userRecord.email,
        customClaims: userRecord.customClaims || {},
        disabled: userRecord.disabled,
        emailVerified: userRecord.emailVerified,
      };
    } catch (error) {
      throw new BadRequestException(`Failed to get user claims: ${error.message}`);
    }
  }

  /**
   * Verify ID token and return user info
   */
  @Public()
  @Post('verify-token')
  async verifyToken(@Body() { idToken }: { idToken: string }) {
    try {
      const decodedToken = await this.firebaseService.verifyIdToken(idToken);
      
      return {
        uid: decodedToken.uid,
        email: decodedToken.email,
        role: decodedToken.role,
        roleValue: decodedToken.roleValue,
        emailVerified: decodedToken.email_verified,
      };
    } catch (error) {
      // Firebase auth errors should return 401 Unauthorized
      throw new BadRequestException(`Invalid token: ${error.message}`);
    }
  }

  /**
   * Synchronize Firebase user with local database
   * Called after user registration/login
   * 
   * @param userData - User data from Firebase
   * @returns Synchronized user information
   */
  @Public()
  @Post('sync-user')
  async syncUser(@Body() userData: {
    uid: string;
    email: string;
    name?: string;
    role: 'client' | 'craftsman';
    phoneNumber?: string;
  }) {
    try {
      const localUser = await this.userSyncService.syncUser(userData);
      
      return {
        success: true,
        user: {
          id: localUser.id,
          firebaseUid: localUser.firebaseUid,
          email: localUser.email,
          fullName: localUser.fullName,
          role: localUser.role,
          isVerified: localUser.isVerified,
        },
      };
    } catch (error) {
      throw new InternalServerErrorException(`User synchronization failed: ${error.message}`);
    }
  }

  /**
   * Get complete user profile (Firebase + local data)
   * 
   * @param uid - Firebase user UID
   * @returns Complete user profile
   */
  @Public()
  @Post('get-profile')
  async getProfile(@Body() { uid }: { uid: string }) {
    try {
      const profile = await this.userSyncService.getCompleteUserProfile(uid);
      
      if (!profile) {
        throw new BadRequestException('User not found');
      }
      
      return {
        success: true,
        profile,
      };
    } catch (error) {
      throw new BadRequestException(`Failed to get profile: ${error.message}`);
    }
  }
}