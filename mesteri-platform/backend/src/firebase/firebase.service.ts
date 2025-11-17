import { Injectable, UnauthorizedException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { Auth } from 'firebase-admin/auth';
import { Firestore } from 'firebase-admin/firestore';

/**
 * Firebase Service - Core Firebase Admin SDK integration
 * 
 * This service handles all Firebase operations including:
 * - User authentication and token verification
 * - Custom claims management for role-based access
 * - Firestore database operations
 * - User synchronization between Firebase and PostgreSQL
 * 
 * @author Archyt - Principal Engineer
 * @version 1.0.0
 */
@Injectable()
export class FirebaseService {
  private readonly logger = new Logger(FirebaseService.name);
  private readonly auth: Auth;
  private readonly firestore: Firestore;

  constructor(private configService: ConfigService) {
    // Initialize Firebase Admin SDK
    const serviceAccountKey = this.configService.get<string>('FIREBASE_SERVICE_ACCOUNT_KEY');
    const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');

    if (!serviceAccountKey || !projectId) {
      throw new Error('Firebase configuration missing. Check FIREBASE_SERVICE_ACCOUNT_KEY and FIREBASE_PROJECT_ID');
    }

    try {
      const serviceAccount = JSON.parse(serviceAccountKey);
      
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: projectId,
      });

      this.auth = admin.auth();
      this.firestore = admin.firestore();
      
      this.logger.log(`Firebase Admin SDK initialized for project: ${projectId}`);
    } catch (error) {
      this.logger.error('Failed to initialize Firebase Admin SDK:', error);
      throw error;
    }
  }

  /**
   * Verify Firebase ID token and extract user information
   * 
   * @param idToken - Firebase ID token from client
   * @returns Decoded token with user information and custom claims
   */
  async verifyIdToken(idToken: string): Promise<admin.auth.DecodedIdToken> {
    try {
      const decodedToken = await this.auth.verifyIdToken(idToken);
      this.logger.debug(`Token verified for user: ${decodedToken.uid}`);
      return decodedToken;
    } catch (error) {
      this.logger.error('Token verification failed:', error);
      throw new UnauthorizedException('Invalid or expired token');
    }
  }

  /**
   * Set custom claims for user role management
   * 
   * @param uid - Firebase user UID
   * @param role - User role: 'client' (0) or 'craftsman' (1)
   * @param additionalClaims - Any additional custom claims
   */
  async setCustomClaims(
    uid: string, 
    role: 'client' | 'craftsman', 
    additionalClaims: Record<string, any> = {}
  ): Promise<void> {
    try {
      const claims = {
        role,
        roleCode: role === 'client' ? 0 : 1,
        ...additionalClaims,
      };

      await this.auth.setCustomUserClaims(uid, claims);
      this.logger.log(`Custom claims set for user ${uid}: ${JSON.stringify(claims)}`);
    } catch (error) {
      this.logger.error(`Failed to set custom claims for user ${uid}:`, error);
      throw error;
    }
  }

  /**
   * Get user by Firebase UID
   * 
   * @param uid - Firebase user UID
   * @returns Firebase user record
   */
  async getUserByUid(uid: string): Promise<admin.auth.UserRecord> {
    try {
      const userRecord = await this.auth.getUser(uid);
      return userRecord;
    } catch (error) {
      this.logger.error(`Failed to get user ${uid}:`, error);
      throw error;
    }
  }

  /**
   * Get user by email address
   * 
   * @param email - User email address
   * @returns Firebase user record
   */
  async getUserByEmail(email: string): Promise<admin.auth.UserRecord> {
    try {
      const userRecord = await this.auth.getUserByEmail(email);
      return userRecord;
    } catch (error) {
      this.logger.error(`Failed to get user by email ${email}:`, error);
      throw error;
    }
  }

  /**
   * Create Firestore document
   * 
   * @param collection - Collection name
   * @param docId - Document ID
   * @param data - Document data
   */
  async createDocument(collection: string, docId: string, data: any): Promise<void> {
    try {
      // Filter undefined values to prevent Firestore errors
      const cleanedData = this.filterUndefinedValues(data);
      await this.firestore.collection(collection).doc(docId).set(cleanedData);
      this.logger.debug(`Document created: ${collection}/${docId}`);
    } catch (error) {
      this.logger.error(`Failed to create document ${collection}/${docId}:`, error);
      throw error;
    }
  }

  /**
   * Get Firestore document
   * 
   * @param collection - Collection name
   * @param docId - Document ID
   * @returns Document data or null if not found
   */
  async getDocument(collection: string, docId: string): Promise<any | null> {
    try {
      const doc = await this.firestore.collection(collection).doc(docId).get();
      return doc.exists ? doc.data() : null;
    } catch (error) {
      this.logger.error(`Failed to get document ${collection}/${docId}:`, error);
      throw error;
    }
  }

  /**
   * Update Firestore document
   * 
   * @param collection - Collection name
   * @param docId - Document ID
   * @param data - Updated data
   */
  async updateDocument(collection: string, docId: string, data: any): Promise<void> {
    try {
      await this.firestore.collection(collection).doc(docId).update(data);
      this.logger.debug(`Document updated: ${collection}/${docId}`);
    } catch (error) {
      this.logger.error(`Failed to update document ${collection}/${docId}:`, error);
      throw error;
    }
  }

  /**
   * Delete Firebase user account
   * 
   * @param uid - Firebase user UID
   */
  async deleteUser(uid: string): Promise<void> {
    try {
      await this.auth.deleteUser(uid);
      this.logger.log(`User deleted: ${uid}`);
    } catch (error) {
      this.logger.error(`Failed to delete user ${uid}:`, error);
      throw error;
    }
  }

  /**
   * Filter out undefined values from an object for Firestore compatibility
   * 
   * @param obj - Object to filter
   * @returns Object with undefined values removed
   */
  private filterUndefinedValues(obj: Record<string, any>): Record<string, any> {
    const filtered: Record<string, any> = {};
    
    for (const [key, value] of Object.entries(obj)) {
      if (value !== undefined) {
        filtered[key] = value;
      }
    }
    
    return filtered;
  }

  /**
   * Create user profile in Firestore
   * 
   * @param uid - Firebase user UID
   * @param profileData - User profile data
   */
  async createUserProfile(uid: string, profileData: any): Promise<void> {
    try {
      const userData = {
        ...profileData,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Filter out undefined values to prevent Firestore errors
      const cleanedUserData = this.filterUndefinedValues(userData);

      await this.createDocument('users', uid, cleanedUserData);
      this.logger.log(`User profile created for: ${uid}`);
    } catch (error) {
      this.logger.error(`Failed to create user profile for ${uid}:`, error);
      throw error;
    }
  }
}