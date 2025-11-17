import { NotificationsService } from './notifications.service';
import { PushNotificationService } from './push-notification.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';
import { RegisterDeviceTokenDto } from './dto/register-device-token.dto';
import { RemoveDeviceTokenDto } from './dto/remove-device-token.dto';
import { TestPushNotificationDto } from './dto/test-push-notification.dto';
import { UpdateNotificationPreferenceDto } from './dto/update-notification-preference.dto';
import { PrismaService } from '../prisma/prisma.service';
export declare class NotificationsController {
    private readonly notificationsService;
    private readonly pushNotificationService;
    private readonly prisma;
    constructor(notificationsService: NotificationsService, pushNotificationService: PushNotificationService, prisma: PrismaService);
    findAll(userId?: string): Promise<{
        id: string;
        createdAt: Date;
        title: string;
        jobId: string | null;
        type: string;
        message: string;
        isRead: boolean;
        userId: string;
    }[]>;
    findOne(id: string, userId?: string): Promise<{
        id: string;
        createdAt: Date;
        title: string;
        jobId: string | null;
        type: string;
        message: string;
        isRead: boolean;
        userId: string;
    }>;
    create(createNotificationDto: CreateNotificationDto): Promise<{
        id: string;
        createdAt: Date;
        title: string;
        jobId: string | null;
        type: string;
        message: string;
        isRead: boolean;
        userId: string;
    }>;
    update(id: string, updateNotificationDto: UpdateNotificationDto, userId?: string): Promise<{
        id: string;
        createdAt: Date;
        title: string;
        jobId: string | null;
        type: string;
        message: string;
        isRead: boolean;
        userId: string;
    }>;
    delete(id: string, userId?: string): Promise<void>;
    markAsRead(id: string, userId?: string): Promise<{
        id: string;
        createdAt: Date;
        title: string;
        jobId: string | null;
        type: string;
        message: string;
        isRead: boolean;
        userId: string;
    }>;
    findUnread(userId: string): Promise<{
        id: string;
        createdAt: Date;
        title: string;
        jobId: string | null;
        type: string;
        message: string;
        isRead: boolean;
        userId: string;
    }[]>;
    registerDeviceToken(dto: RegisterDeviceTokenDto, req: any): Promise<{
        id: string;
        createdAt: Date;
        token: string;
        userId: string;
        platform: import("@prisma/client").$Enums.DevicePlatform;
        lastUsedAt: Date;
    }>;
    removeDeviceToken(dto: RemoveDeviceTokenDto, req: any): Promise<{
        message: string;
    }>;
    testPushNotification(dto: TestPushNotificationDto, req: any): Promise<import("./push-notification.service").NotificationResult>;
    getNotificationHistory(userId: string, req: any): Promise<{
        id: string;
        createdAt: Date;
        title: string | null;
        status: import("@prisma/client").$Enums.NotificationStatus;
        type: import("@prisma/client").$Enums.NotificationType;
        body: string | null;
        metadata: import("@prisma/client/runtime/library").JsonValue | null;
        sentAt: Date;
        userId: string;
        channel: import("@prisma/client").$Enums.NotificationChannel;
        deliveredAt: Date | null;
        errorMessage: string | null;
    }[]>;
    getNotificationPreferences(userId: string, req: any): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        notificationType: import("@prisma/client").$Enums.NotificationType;
        pushEnabled: boolean;
        emailEnabled: boolean;
    }[]>;
    updateNotificationPreference(userId: string, dto: UpdateNotificationPreferenceDto, req: any): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        notificationType: import("@prisma/client").$Enums.NotificationType;
        pushEnabled: boolean;
        emailEnabled: boolean;
    }>;
    unsubscribeFromEmails(token: string): Promise<{
        message: string;
    }>;
}
