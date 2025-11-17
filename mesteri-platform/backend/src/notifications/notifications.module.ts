import { Module } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { NotificationsController } from './notifications.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { PushNotificationService } from './push-notification.service';
import { EmailNotificationService } from './email-notification.service';

@Module({
  imports: [PrismaModule],
  controllers: [NotificationsController],
  providers: [
    NotificationsService,
    PushNotificationService,
    EmailNotificationService,
  ],
  exports: [
    NotificationsService,
    PushNotificationService,
    EmailNotificationService,
  ],
})
export class NotificationsModule {}
