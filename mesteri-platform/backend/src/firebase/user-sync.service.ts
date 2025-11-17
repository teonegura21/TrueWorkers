import { Injectable, Logger } from '@nestjs/common';
import { FirebaseService } from './firebase.service';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole, UserType } from '@prisma/client';

/**
 * User Synchronization Service
 * 
 * Handles synchronization between Firebase Auth users and PostgreSQL database
 * Creates local user records when Firebase users authenticate
 * 
 * @author Archyt - Principal Engineer
 * @version 1.0.0
 */

interface SyncUserData {
  uid: string;
  email: string;
  name?: string;
  role: 'client' | 'craftsman';
  phoneNumber?: string;
}

@Injectable()
export class UserSyncService {
  private readonly logger = new Logger(UserSyncService.name);

  constructor(
    private firebaseService: FirebaseService,
    private prisma: PrismaService,
  ) {}

  /**
   * Synchronize Firebase user with PostgreSQL database
   * Creates or updates local user record
   * 
   * @param userData - User data from Firebase authentication
   * @returns Local user record
   */
  async syncUser(userData: SyncUserData) {
    try {
      // Check if user already exists in local database
      let localUser = await this.prisma.user.findUnique({
        where: { firebaseUid: userData.uid },
      });

      if (localUser) {
        // Update existing user
        localUser = await this.prisma.user.update({
          where: { id: localUser.id },
          data: {
            email: userData.email,
            fullName: userData.name || localUser.fullName,
            phone: userData.phoneNumber || localUser.phone,
            updatedAt: new Date(),
          },
        });

        this.logger.log(`Updated existing user: ${userData.email}`);
      } else {
        // Create new user
        localUser = await this.prisma.user.create({
          data: {
            firebaseUid: userData.uid,
            email: userData.email,
            fullName: userData.name || 'Unknown User',
            role: userData.role === 'client' ? UserRole.CLIENT : UserRole.CRAFTSMAN,
            userType: UserType.INDIVIDUAL,
            phone: userData.phoneNumber,
            city: 'Unknown',
            county: 'Unknown',
            specialties: [],
            isVerified: false,
            averageRating: 5.0,
            totalReviews: 0,
          },
        });

        this.logger.log(`Created new user: ${userData.email}`);

        // Create user profile in Firestore (filter out undefined values)
        const firestoreProfileData: Record<string, any> = {
          localUserId: localUser.id,
          email: userData.email,
          name: userData.name || 'Unknown User',
          role: userData.role,
          isVerified: false,
          createdAt: new Date().toISOString(),
        };

        // Only add phoneNumber if it's defined
        if (userData.phoneNumber) {
          firestoreProfileData.phoneNumber = userData.phoneNumber;
        }

        await this.firebaseService.createUserProfile(userData.uid, firestoreProfileData);
      }

      return localUser;
    } catch (error) {
      this.logger.error(`Failed to sync user ${userData.email}:`, error);
      throw error;
    }
  }

  /**
   * Get user by Firebase UID
   * 
   * @param firebaseUid - Firebase user UID
   * @returns Local user record or null
   */
  async getUserByFirebaseUid(firebaseUid: string) {
    try {
      return await this.prisma.user.findUnique({
        where: { firebaseUid },
      });
    } catch (error) {
      this.logger.error(`Failed to get user by Firebase UID ${firebaseUid}:`, error);
      return null;
    }
  }

  /**
   * Update user profile from Firebase data
   * 
   * @param firebaseUid - Firebase user UID
   * @param updates - Profile updates
   * @returns Updated user record
   */
  async updateUserProfile(firebaseUid: string, updates: Partial<SyncUserData>) {
    try {
      const user = await this.prisma.user.findUnique({
        where: { firebaseUid },
      });

      if (!user) {
        throw new Error('User not found');
      }

      const updatedUser = await this.prisma.user.update({
        where: { id: user.id },
        data: {
          email: updates.email || user.email,
          fullName: updates.name || user.fullName,
          phone: updates.phoneNumber || user.phone,
          updatedAt: new Date(),
        },
      });

      this.logger.log(`Updated user profile: ${updatedUser.email}`);
      return updatedUser;
    } catch (error) {
      this.logger.error(`Failed to update user profile ${firebaseUid}:`, error);
      throw error;
    }
  }

  /**
   * Delete user from both Firebase and PostgreSQL
   * 
   * @param firebaseUid - Firebase user UID
   */
  async deleteUser(firebaseUid: string) {
    try {
      // Delete from PostgreSQL
      await this.prisma.user.delete({
        where: { firebaseUid },
      });

      // Delete from Firebase Auth
      await this.firebaseService.deleteUser(firebaseUid);

      this.logger.log(`Deleted user: ${firebaseUid}`);
    } catch (error) {
      this.logger.error(`Failed to delete user ${firebaseUid}:`, error);
      throw error;
    }
  }

  /**
   * Verify user exists and return complete profile
   * 
   * @param firebaseUid - Firebase user UID
   * @returns Complete user profile with Firebase and local data
   */
  async getCompleteUserProfile(firebaseUid: string) {
    try {
      // Get local user
      const localUser = await this.getUserByFirebaseUid(firebaseUid);
      if (!localUser) {
        return null;
      }

      // Get Firebase user data
      const firebaseUser = await this.firebaseService.getUserByUid(firebaseUid);

      // Get Firestore profile
      const firestoreProfile = await this.firebaseService.getDocument('users', firebaseUid);

      return {
        local: localUser,
        firebase: {
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName,
          emailVerified: firebaseUser.emailVerified,
          phoneNumber: firebaseUser.phoneNumber,
          customClaims: firebaseUser.customClaims,
        },
        firestore: firestoreProfile,
      };
    } catch (error) {
      this.logger.error(`Failed to get complete user profile ${firebaseUid}:`, error);
      return null;
    }
  }
}