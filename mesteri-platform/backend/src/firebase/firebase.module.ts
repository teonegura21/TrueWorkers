import { Module, Global } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { FirebaseService } from './firebase.service';
import { FirebaseAuthController } from './firebase-auth.controller';
import { UserSyncService } from './user-sync.service';

/**
 * Firebase Module - Global module for Firebase Admin SDK integration
 * 
 * This module provides Firebase Admin SDK functionality across the entire application
 * including authentication token verification, Firestore operations, and user management.
 * 
 * @author Archyt - Principal Engineer
 * @version 1.0.0
 */
@Global()
@Module({
  imports: [ConfigModule],
  controllers: [FirebaseAuthController],
  providers: [
    {
      provide: FirebaseService,
      useFactory: (configService: ConfigService) => {
        return new FirebaseService(configService);
      },
      inject: [ConfigService],
    },
    UserSyncService,
  ],
  exports: [FirebaseService, UserSyncService],
})
export class FirebaseModule {}