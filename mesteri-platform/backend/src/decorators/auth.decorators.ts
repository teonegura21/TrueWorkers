import { SetMetadata } from '@nestjs/common';

/**
 * Public Route Decorator
 * 
 * Use this decorator to mark routes as public (no authentication required).
 * This bypasses the FirebaseAuthGuard for specific endpoints.
 * 
 * @example
 * @Public()
 * @Get('health')
 * getHealth() {
 *   return { status: 'ok' };
 * }
 * 
 * @author Archyt - Principal Engineer
 */
export const Public = () => SetMetadata('isPublic', true);

/**
 * Roles Decorator
 * 
 * Use this decorator to specify required user roles for accessing a route.
 * Works in conjunction with FirebaseAuthGuard for role-based access control.
 * 
 * @param roles - Array of allowed roles ('client', 'craftsman', etc.)
 * 
 * @example
 * @Roles('craftsman')
 * @Get('craftsman-only')
 * getCraftsmanData() {
 *   return { data: 'craftsman specific data' };
 * }
 * 
 * @author Archyt - Principal Engineer
 */
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);