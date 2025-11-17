"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var PushNotificationService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.PushNotificationService = exports.NotificationStatus = exports.NotificationChannel = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const admin = __importStar(require("firebase-admin"));
const prisma_service_1 = require("../prisma/prisma.service");
const update_notification_preference_dto_1 = require("./dto/update-notification-preference.dto");
var NotificationChannel;
(function (NotificationChannel) {
    NotificationChannel["PUSH"] = "PUSH";
    NotificationChannel["EMAIL"] = "EMAIL";
})(NotificationChannel || (exports.NotificationChannel = NotificationChannel = {}));
var NotificationStatus;
(function (NotificationStatus) {
    NotificationStatus["PENDING"] = "PENDING";
    NotificationStatus["SENT"] = "SENT";
    NotificationStatus["DELIVERED"] = "DELIVERED";
    NotificationStatus["FAILED"] = "FAILED";
    NotificationStatus["BOUNCED"] = "BOUNCED";
})(NotificationStatus || (exports.NotificationStatus = NotificationStatus = {}));
let PushNotificationService = PushNotificationService_1 = class PushNotificationService {
    prisma;
    configService;
    logger = new common_1.Logger(PushNotificationService_1.name);
    maxRetries = 3;
    retryEnabled = true;
    constructor(prisma, configService) {
        this.prisma = prisma;
        this.configService = configService;
        this.retryEnabled =
            this.configService.get('NOTIFICATION_RETRY_ENABLED', 'true') === 'true';
    }
    async onModuleInit() {
        await this.initializeFirebase();
    }
    async initializeFirebase() {
        try {
            const serviceAccountPath = this.configService.get('FIREBASE_SERVICE_ACCOUNT_PATH');
            if (!serviceAccountPath) {
                this.logger.warn('FIREBASE_SERVICE_ACCOUNT_PATH not configured. Push notifications will be disabled.');
                return;
            }
            if (admin.apps.length === 0) {
                const serviceAccount = require(serviceAccountPath);
                admin.initializeApp({
                    credential: admin.credential.cert(serviceAccount),
                });
                this.logger.log('Firebase Admin SDK initialized successfully');
            }
            else {
                this.logger.log('Firebase Admin SDK already initialized');
            }
        }
        catch (error) {
            this.logger.error('Failed to initialize Firebase Admin SDK', error.stack);
        }
    }
    async sendPushNotification(userId, title, body, data) {
        try {
            const deviceTokens = await this.prisma.deviceToken.findMany({
                where: { userId },
            });
            if (deviceTokens.length === 0) {
                this.logger.warn(`No device tokens found for user ${userId}`);
                await this.logNotification({
                    userId,
                    type: data?.type || update_notification_preference_dto_1.NotificationType.NEW_MESSAGE,
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
            const message = {
                tokens,
                notification: {
                    title,
                    body,
                },
                data: data
                    ? Object.fromEntries(Object.entries(data).map(([key, value]) => [
                        key,
                        typeof value === 'string' ? value : JSON.stringify(value),
                    ]))
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
            const successfulTokens = [];
            const failedTokens = [];
            response.responses.forEach((resp, idx) => {
                if (resp.success) {
                    successfulTokens.push(tokens[idx]);
                }
                else {
                    failedTokens.push(tokens[idx]);
                    this.logger.error(`Failed to send to token ${tokens[idx]}: ${resp.error?.message}`);
                }
            });
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
            if (failedTokens.length > 0) {
                for (const token of failedTokens) {
                    const respIndex = tokens.indexOf(token);
                    const error = response.responses[respIndex].error;
                    if (error?.code === 'messaging/invalid-registration-token' ||
                        error?.code === 'messaging/registration-token-not-registered') {
                        await this.removeDeviceToken(userId, token);
                        this.logger.log(`Removed invalid token for user ${userId}`);
                    }
                }
            }
            await this.logNotification({
                userId,
                type: data?.type || update_notification_preference_dto_1.NotificationType.NEW_MESSAGE,
                channel: NotificationChannel.PUSH,
                status: response.successCount > 0
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
                errorMessage: response.failureCount > 0
                    ? `${response.failureCount} tokens failed`
                    : undefined,
            });
            return {
                success: response.successCount > 0,
                messageId: response.responses[0]?.messageId,
            };
        }
        catch (error) {
            this.logger.error(`Error sending push notification to user ${userId}`, error.stack);
            await this.logNotification({
                userId,
                type: data?.type || update_notification_preference_dto_1.NotificationType.NEW_MESSAGE,
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
    async sendToMultipleDevices(userIds, notification) {
        const results = [];
        let successCount = 0;
        let failureCount = 0;
        for (const userId of userIds) {
            const result = await this.sendPushNotification(userId, notification.title, notification.body, notification.data);
            results.push(result);
            if (result.success) {
                successCount++;
            }
            else {
                failureCount++;
            }
        }
        return {
            successCount,
            failureCount,
            results,
        };
    }
    async registerDeviceToken(userId, token, platform) {
        try {
            const existingToken = await this.prisma.deviceToken.findFirst({
                where: {
                    userId,
                    token,
                },
            });
            if (existingToken) {
                return await this.prisma.deviceToken.update({
                    where: { id: existingToken.id },
                    data: {
                        lastUsedAt: new Date(),
                        platform,
                    },
                });
            }
            return await this.prisma.deviceToken.create({
                data: {
                    userId,
                    token,
                    platform,
                },
            });
        }
        catch (error) {
            this.logger.error(`Error registering device token for user ${userId}`, error.stack);
            throw error;
        }
    }
    async removeDeviceToken(userId, token) {
        try {
            await this.prisma.deviceToken.deleteMany({
                where: {
                    userId,
                    token,
                },
            });
            this.logger.log(`Removed device token for user ${userId}`);
        }
        catch (error) {
            this.logger.error(`Error removing device token for user ${userId}`, error.stack);
            throw error;
        }
    }
    async refreshTokenStatus(userId, token) {
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
        }
        catch (error) {
            this.logger.error(`Error refreshing token status for user ${userId}`, error.stack);
        }
    }
    async onNewJobOffer(craftsmanId, jobData) {
        await this.sendPushNotification(craftsmanId, 'Ofertă nouă de lucru', `${jobData.jobTitle} în ${jobData.location}`, {
            type: update_notification_preference_dto_1.NotificationType.NEW_JOB,
            jobId: jobData.jobId,
            category: jobData.category,
            location: jobData.location,
            budget: jobData.budget,
        });
    }
    async onOfferAccepted(craftsmanId, offerData) {
        await this.sendPushNotification(craftsmanId, 'Oferta ta a fost acceptată!', `${offerData.clientName} a acceptat oferta ta de ${offerData.acceptedAmount} RON`, {
            type: update_notification_preference_dto_1.NotificationType.OFFER_ACCEPTED,
            offerId: offerData.offerId,
            jobId: offerData.jobId,
            clientName: offerData.clientName,
            acceptedAmount: offerData.acceptedAmount.toString(),
        });
    }
    async onContractSigned(userId, contractData) {
        await this.sendPushNotification(userId, 'Contract semnat', `${contractData.signerRole} a semnat contractul`, {
            type: update_notification_preference_dto_1.NotificationType.CONTRACT_SIGNED,
            contractId: contractData.contractId,
            projectId: contractData.projectId,
            signerRole: contractData.signerRole,
        });
    }
    async onPaymentReceived(craftsmanId, paymentData) {
        await this.sendPushNotification(craftsmanId, 'Plată primită', `Ai primit ${paymentData.amount} RON pentru ${paymentData.projectTitle}`, {
            type: update_notification_preference_dto_1.NotificationType.PAYMENT_RECEIVED,
            paymentId: paymentData.paymentId,
            amount: paymentData.amount.toString(),
            projectTitle: paymentData.projectTitle,
        });
    }
    async onNewMessage(userId, messageData) {
        await this.sendPushNotification(userId, `Mesaj nou de la ${messageData.senderName}`, messageData.messagePreview, {
            type: update_notification_preference_dto_1.NotificationType.NEW_MESSAGE,
            conversationId: messageData.conversationId,
            senderId: messageData.senderId,
            senderName: messageData.senderName,
        });
    }
    async logNotification(data) {
        try {
            await this.prisma.notificationLog.create({
                data,
            });
        }
        catch (error) {
            this.logger.error('Error logging notification', error.stack);
        }
    }
};
exports.PushNotificationService = PushNotificationService;
exports.PushNotificationService = PushNotificationService = PushNotificationService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        config_1.ConfigService])
], PushNotificationService);
//# sourceMappingURL=push-notification.service.js.map