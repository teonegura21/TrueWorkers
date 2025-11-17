import { Request } from 'express';

/**
 * Firebase user info attached to request by FirebaseAuthGuard
 */
export interface FirebaseUser {
  uid: string;
  email?: string;
  email_verified?: boolean;
  name?: string;
  picture?: string;
  [key: string]: unknown;
}

/**
 * Express Request with Firebase authentication
 */
export interface FirebaseAuthenticatedRequest extends Request {
  user?: FirebaseUser;
}
