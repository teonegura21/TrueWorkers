import { OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { DevicePlatform } from './dto/register-device-token.dto';
export declare enum NotificationChannel {
    PUSH = "PUSH",
    EMAIL = "EMAIL"
}
export declare enum NotificationStatus {
    PENDING = "PENDING",
    SENT = "SENT",
    DELIVERED = "DELIVERED",
    FAILED = "FAILED",
    BOUNCED = "BOUNCED"
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
export declare class PushNotificationService implements OnModuleInit {
    private prisma;
    private configService;
    private readonly logger;
    private readonly maxRetries;
    private readonly retryEnabled;
    constructor(prisma: PrismaService, configService: ConfigService);
    onModuleInit(): Promise<void>;
    private initializeFirebase;
    sendPushNotification(userId: string, title: string, body: string, data?: Record<string, any>): Promise<NotificationResult>;
    sendToMultipleDevices(userIds: string[], notification: {
        title: string;
        body: string;
        data?: Record<string, any>;
    }): Promise<BatchNotificationResult>;
    registerDeviceToken(userId: string, token: string, platform: DevicePlatform): Promise<{
        id: string;
        createdAt: Date;
        token: string;
        userId: string;
        platform: import("@prisma/client").$Enums.DevicePlatform;
        lastUsedAt: Date;
    }>;
    removeDeviceToken(userId: string, token: string): Promise<void>;
    refreshTokenStatus(userId: string, token: string): Promise<void>;
    onNewJobOffer(craftsmanId: string, jobData: {
        jobId: string;
        jobTitle: string;
        category: string;
        location: string;
        budget: string;
    }): Promise<void>;
    onOfferAccepted(craftsmanId: string, offerData: {
        offerId: string;
        jobId: string;
        clientName: string;
        acceptedAmount: number;
    }): Promise<void>;
    onContractSigned(userId: string, contractData: {
        contractId: string;
        projectId: string;
        signerRole: string;
    }): Promise<void>;
    onPaymentReceived(craftsmanId: string, paymentData: {
        paymentId: string;
        amount: number;
        projectTitle: string;
    }): Promise<void>;
    onNewMessage(userId: string, messageData: {
        conversationId: string;
        senderId: string;
        senderName: string;
        messagePreview: string;
    }): Promise<void>;
    private logNotification;
}
