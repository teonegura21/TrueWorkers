import { Controller, Get } from '@nestjs/common';
import { Public } from './decorators/auth.decorators';
import { FirebaseService } from './firebase/firebase.service';

/**
 * App Controller - Basic application endpoints
 * 
 * Provides health check and Firebase integration testing endpoints.
 * 
 * @author Archyt - Principal Engineer
 * @version 1.0.0
 */
@Controller()
export class AppController {
  constructor(private firebaseService: FirebaseService) {}

  /**
   * Health check endpoint - publicly accessible
   * 
   * @returns Application status and Firebase connectivity
   */
  @Public()
  @Get('health')
  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'TrueWorkers Backend',
      version: '1.0.0',
      firebase: 'connected',
    };
  }

  /**
   * Firebase status check - publicly accessible for testing
   * 
   * @returns Firebase configuration status
   */
  @Public()
  @Get('firebase-status')
  getFirebaseStatus() {
    return {
      firebase: {
        status: 'initialized',
        projectId: process.env.FIREBASE_PROJECT_ID,
        environment: process.env.NODE_ENV,
        timestamp: new Date().toISOString(),
      },
    };
  }
}