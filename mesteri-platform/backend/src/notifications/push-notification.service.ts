import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { PrismaService } from '../prisma/prisma.service';
import { DevicePlatform } from './dto/register-device-token.dto';
import { NotificationType } from './dto/update-notification-preference.dto';

export enum NotificationChannel {
  PUSH = 'PUSH',
  EMAIL = 'EMAIL',
}

export enum NotificationStatus {
  PENDING = 'PENDING',
  SENT = 'SENT',
  DELIVERED = 'DELIVERED',
  FAILED = 'FAILED',
  BOUNCED = 'BOUNCED',
}

export interface NotificationResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

export interface BatchNotificationResult {
  successCount: number;
  failureCount: number;
  results: NotificationResult[];
}

@Injectable()
export class PushNotificationService implements OnModuleInit {
  private readonly logger = new Logger(PushNotificationService.name);
  private readonly maxRetries: number = 3;
  private readonly retryEnabled: boolean = true;

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {
    this.retryEnabled =
      this.configService.get('NOTIFICATION_RETRY_ENABLED', 'true') === 'true';
  }

  async onModuleInit() {
    await this.initializeFirebase();
  }

  private async initializeFirebase(): Promise<void> {
    try {
      const serviceAccountPath = this.configService.get<string>(
        'FIREBASE_SERVICE_ACCOUNT_PATH',
      );

      if (!serviceAccountPath) {
        this.logger.warn(
          'FIREBASE_SERVICE_ACCOUNT_PATH not configured. Push notifications will be disabled.',
        );
        return;
      }

      // Check if Firebase Admin is already initialized
      if (admin.apps.length === 0) {
        const serviceAccount = require(serviceAccountPath);
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
        this.logger.log('Firebase Admin SDK initialized successfully');
      } else {
        this.logger.log('Firebase Admin SDK already initialized');
      }
    } catch (error) {
      this.logger.error(
        'Failed to initialize Firebase Admin SDK',
        error.stack,
      );
    }
  }

  async sendPushNotification(
    userId: string,
    title: string,
    body: string,
    data?: Record<string, any>,
  ): Promise<NotificationResult> {
    try {
      // Get user's device tokens
      const deviceTokens = await this.prisma.deviceToken.findMany({
        where: { userId },
      });

      if (deviceTokens.length === 0) {
        this.logger.warn(`No device tokens found for user ${userId}`);
        await this.logNotification({
          userId,
          type: data?.type || NotificationType.NEW_MESSAGE,
          channel: NotificationChannel.PUSH,
          status: NotificationStatus.FAILED,
          title,
          body,
          metadata: data,
          errorMessage: 'No device tokens registered',
        });
        return {
          success: false,
          error: 'No device tokens registered for user',
        };
      }

      const tokens = deviceTokens.map((dt) => dt.token);
      const message: admin.messaging.MulticastMessage = {
        tokens,
        notification: {
          title,
          body,
        },
        data: data
          ? Object.fromEntries(
              Object.entries(data).map(([key, value]) => [
                key,
                typeof value === 'string' ? value : JSON.stringify(value),
              ]),
            )
          : {},
        android: {
          priority: 'high',
          notification: {
            priority: 'high',
            channelId: 'mesteri_notifications',
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title,
                body,
              },
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().sendEachForMulticast(message);

      // Update lastUsedAt for successful tokens
      const successfulTokens: string[] = [];
      const failedTokens: string[] = [];

      response.responses.forEach((resp, idx) => {
        if (resp.success) {
          successfulTokens.push(tokens[idx]);
        } else {
          failedTokens.push(tokens[idx]);
          this.logger.error(
            `Failed to send to token ${tokens[idx]}: ${resp.error?.message}`,
          );
        }
      });

      // Update successful tokens
      if (successfulTokens.length > 0) {
        await this.prisma.deviceToken.updateMany({
          where: {
            userId,
            token: { in: successfulTokens },
          },
          data: {
            lastUsedAt: new Date(),
          },
        });
      }

      // Remove invalid tokens
      if (failedTokens.length > 0) {
        for (const token of failedTokens) {
          const respIndex = tokens.indexOf(token);
          const error = response.responses[respIndex].error;

          if (
            error?.code === 'messaging/invalid-registration-token' ||
            error?.code === 'messaging/registration-token-not-registered'
          ) {
            await this.removeDeviceToken(userId, token);
            this.logger.log(`Removed invalid token for user ${userId}`);
          }
        }
      }

      // Log notification
      await this.logNotification({
        userId,
        type: data?.type || NotificationType.NEW_MESSAGE,
        channel: NotificationChannel.PUSH,
        status:
          response.successCount > 0
            ? NotificationStatus.SENT
            : NotificationStatus.FAILED,
        title,
        body,
        metadata: {
          ...data,
          successCount: response.successCount,
          failureCount: response.failureCount,
        },
        deliveredAt: response.successCount > 0 ? new Date() : undefined,
        errorMessage:
          response.failureCount > 0
            ? `${response.failureCount} tokens failed`
            : undefined,
      });

      return {
        success: response.successCount > 0,
        messageId: response.responses[0]?.messageId,
      };
    } catch (error) {
      this.logger.error(
        `Error sending push notification to user ${userId}`,
        error.stack,
      );
      await this.logNotification({
        userId,
        type: data?.type || NotificationType.NEW_MESSAGE,
        channel: NotificationChannel.PUSH,
        status: NotificationStatus.FAILED,
        title,
        body,
        metadata: data,
        errorMessage: error.message,
      });
      return {
        success: false,
        error: error.message,
      };
    }
  }

  async sendToMultipleDevices(
    userIds: string[],
    notification: {
      title: string;
      body: string;
      data?: Record<string, any>;
    },
  ): Promise<BatchNotificationResult> {
    const results: NotificationResult[] = [];
    let successCount = 0;
    let failureCount = 0;

    for (const userId of userIds) {
      const result = await this.sendPushNotification(
        userId,
        notification.title,
        notification.body,
        notification.data,
      );

      results.push(result);
      if (result.success) {
        successCount++;
      } else {
        failureCount++;
      }
    }

    return {
      successCount,
      failureCount,
      results,
    };
  }

  async registerDeviceToken(
    userId: string,
    token: string,
    platform: DevicePlatform,
  ) {
    try {
      // Check if token already exists
      const existingToken = await this.prisma.deviceToken.findFirst({
        where: {
          userId,
          token,
        },
      });

      if (existingToken) {
        // Update lastUsedAt
        return await this.prisma.deviceToken.update({
          where: { id: existingToken.id },
          data: {
            lastUsedAt: new Date(),
            platform, // Update platform in case it changed
          },
        });
      }

      // Create new token
      return await this.prisma.deviceToken.create({
        data: {
          userId,
          token,
          platform,
        },
      });
    } catch (error) {
      this.logger.error(
        `Error registering device token for user ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  async removeDeviceToken(userId: string, token: string): Promise<void> {
    try {
      await this.prisma.deviceToken.deleteMany({
        where: {
          userId,
          token,
        },
      });
      this.logger.log(`Removed device token for user ${userId}`);
    } catch (error) {
      this.logger.error(
        `Error removing device token for user ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  async refreshTokenStatus(userId: string, token: string): Promise<void> {
    try {
      await this.prisma.deviceToken.updateMany({
        where: {
          userId,
          token,
        },
        data: {
          lastUsedAt: new Date(),
        },
      });
    } catch (error) {
      this.logger.error(
        `Error refreshing token status for user ${userId}`,
        error.stack,
      );
    }
  }

  // Event trigger methods
  async onNewJobOffer(
    craftsmanId: string,
    jobData: {
      jobId: string;
      jobTitle: string;
      category: string;
      location: string;
      budget: string;
    },
  ): Promise<void> {
    await this.sendPushNotification(
      craftsmanId,
      'Ofertă nouă de lucru',
      `${jobData.jobTitle} în ${jobData.location}`,
      {
        type: NotificationType.NEW_JOB,
        jobId: jobData.jobId,
        category: jobData.category,
        location: jobData.location,
        budget: jobData.budget,
      },
    );
  }

  async onOfferAccepted(
    craftsmanId: string,
    offerData: {
      offerId: string;
      jobId: string;
      clientName: string;
      acceptedAmount: number;
    },
  ): Promise<void> {
    await this.sendPushNotification(
      craftsmanId,
      'Oferta ta a fost acceptată!',
      `${offerData.clientName} a acceptat oferta ta de ${offerData.acceptedAmount} RON`,
      {
        type: NotificationType.OFFER_ACCEPTED,
        offerId: offerData.offerId,
        jobId: offerData.jobId,
        clientName: offerData.clientName,
        acceptedAmount: offerData.acceptedAmount.toString(),
      },
    );
  }

  async onContractSigned(
    userId: string,
    contractData: {
      contractId: string;
      projectId: string;
      signerRole: string;
    },
  ): Promise<void> {
    await this.sendPushNotification(
      userId,
      'Contract semnat',
      `${contractData.signerRole} a semnat contractul`,
      {
        type: NotificationType.CONTRACT_SIGNED,
        contractId: contractData.contractId,
        projectId: contractData.projectId,
        signerRole: contractData.signerRole,
      },
    );
  }

  async onPaymentReceived(
    craftsmanId: string,
    paymentData: {
      paymentId: string;
      amount: number;
      projectTitle: string;
    },
  ): Promise<void> {
    await this.sendPushNotification(
      craftsmanId,
      'Plată primită',
      `Ai primit ${paymentData.amount} RON pentru ${paymentData.projectTitle}`,
      {
        type: NotificationType.PAYMENT_RECEIVED,
        paymentId: paymentData.paymentId,
        amount: paymentData.amount.toString(),
        projectTitle: paymentData.projectTitle,
      },
    );
  }

  async onNewMessage(
    userId: string,
    messageData: {
      conversationId: string;
      senderId: string;
      senderName: string;
      messagePreview: string;
    },
  ): Promise<void> {
    await this.sendPushNotification(
      userId,
      `Mesaj nou de la ${messageData.senderName}`,
      messageData.messagePreview,
      {
        type: NotificationType.NEW_MESSAGE,
        conversationId: messageData.conversationId,
        senderId: messageData.senderId,
        senderName: messageData.senderName,
      },
    );
  }

  private async logNotification(data: {
    userId: string;
    type: NotificationType;
    channel: NotificationChannel;
    status: NotificationStatus;
    title?: string;
    body?: string;
    metadata?: Record<string, unknown>;
    deliveredAt?: Date;
    errorMessage?: string;
  }): Promise<void> {
    try {
      await this.prisma.notificationLog.create({
        data,
      });
    } catch (error) {
      this.logger.error('Error logging notification', error.stack);
    }
  }
}
