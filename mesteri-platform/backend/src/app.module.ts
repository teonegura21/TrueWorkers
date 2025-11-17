import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { FirebaseModule } from './firebase/firebase.module';
import { FirebaseAuthGuard } from './guards/firebase-auth.guard';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { JobsModule } from './jobs/jobs.module';
import { OffersModule } from './offers/offers.module';
import { ProjectsModule } from './projects/projects.module';
import { PaymentsModule } from './payments/payments.module';
import { ReviewsModule } from './reviews/reviews.module';
import { VerificationModule } from './verification/verification.module';
import { DatabaseModule } from './core/database/database.module';
import { MessagesModule } from './messages/messages.module';
import { NotificationsModule } from './notifications/notifications.module';
import { ConversationsModule } from './conversations/conversations.module';
import { StorageModule } from './storage/storage.module';
import { InspirationModule } from './inspiration/inspiration.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { MediaModule } from './media/media.module';
import { SignRequestModule } from './signrequest/signrequest.module';
import { ContractsModule } from './contracts/contracts.module';
import { AppController } from './app.controller';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    FirebaseModule,
    DatabaseModule,
    AuthModule,
    UsersModule,
    JobsModule,
    OffersModule,
    ProjectsModule,
    PaymentsModule,
    ReviewsModule,
    VerificationModule,
    MessagesModule,
    NotificationsModule,
    ConversationsModule,
    StorageModule,
    InspirationModule,
    AnalyticsModule,
    MediaModule,
    SignRequestModule,
    ContractsModule,
  ],
  controllers: [AppController],
  providers: [
    {
      provide: APP_GUARD,
      useClass: FirebaseAuthGuard,
    },
  ],
})
export class AppModule {}
