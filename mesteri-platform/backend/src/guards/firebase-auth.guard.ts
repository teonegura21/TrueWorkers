import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { FirebaseService } from '../firebase/firebase.service';

/**
 * Firebase Authentication Guard
 * 
 * This guard replaces the JWT authentication system with Firebase token verification.
 * It extracts the Firebase ID token from the Authorization header, verifies it,
 * and attaches the user information to the request object.
 * 
 * Usage:
 * - @UseGuards(FirebaseAuthGuard) on controllers or routes
 * - @Public() decorator to bypass authentication
 * - @Roles('client', 'craftsman') for role-based access
 * 
 * @author Archyt - Principal Engineer
 * @version 1.0.0
 */
@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  private readonly logger = new Logger(FirebaseAuthGuard.name);

  constructor(
    private firebaseService: FirebaseService,
    private reflector: Reflector,
  ) {}

  /**
   * Determine if the request should be allowed to proceed
   * 
   * @param context - Execution context containing request information
   * @returns Promise<boolean> - True if request is authorized
   */
  async canActivate(context: ExecutionContext): Promise<boolean> {
    // Check if route is marked as public
    const isPublic = this.reflector.getAllAndOverride<boolean>('isPublic', [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      this.logger.warn('No token provided in request');
      throw new UnauthorizedException('No authentication token provided');
    }

    try {
      // Verify Firebase ID token
      const decodedToken = await this.firebaseService.verifyIdToken(token);
      
      // Attach user information to request
      request.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
        role: decodedToken.role || 'client',
        roleCode: decodedToken.roleCode || 0,
        emailVerified: decodedToken.email_verified,
        customClaims: decodedToken,
      };

      // Check role-based access if specified
      const requiredRoles = this.reflector.getAllAndOverride<string[]>('roles', [
        context.getHandler(),
        context.getClass(),
      ]);

      if (requiredRoles && !requiredRoles.includes(request.user.role)) {
        this.logger.warn(`User ${request.user.uid} with role ${request.user.role} attempted to access route requiring roles: ${requiredRoles.join(', ')}`);
        throw new UnauthorizedException('Insufficient permissions');
      }

      this.logger.debug(`Authentication successful for user: ${decodedToken.uid}`);
      return true;
    } catch (error) {
      this.logger.error('Authentication failed:', error.message);
      throw new UnauthorizedException('Invalid or expired token');
    }
  }

  /**
   * Extract Bearer token from Authorization header
   * 
   * @param request - HTTP request object
   * @returns Token string or null if not found
   */
  private extractTokenFromHeader(request: any): string | null {
    const authHeader = request.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    return authHeader.substring(7); // Remove 'Bearer ' prefix
  }
}