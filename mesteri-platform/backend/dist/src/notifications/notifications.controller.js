"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationsController = void 0;
const common_1 = require("@nestjs/common");
const notifications_service_1 = require("./notifications.service");
const push_notification_service_1 = require("./push-notification.service");
const create_notification_dto_1 = require("./dto/create-notification.dto");
const update_notification_dto_1 = require("./dto/update-notification.dto");
const register_device_token_dto_1 = require("./dto/register-device-token.dto");
const remove_device_token_dto_1 = require("./dto/remove-device-token.dto");
const test_push_notification_dto_1 = require("./dto/test-push-notification.dto");
const update_notification_preference_dto_1 = require("./dto/update-notification-preference.dto");
const firebase_auth_guard_1 = require("../guards/firebase-auth.guard");
const prisma_service_1 = require("../prisma/prisma.service");
let NotificationsController = class NotificationsController {
    notificationsService;
    pushNotificationService;
    prisma;
    constructor(notificationsService, pushNotificationService, prisma) {
        this.notificationsService = notificationsService;
        this.pushNotificationService = pushNotificationService;
        this.prisma = prisma;
    }
    findAll(userId) {
        return this.notificationsService.findAll(userId);
    }
    findOne(id, userId) {
        return this.notificationsService.findOne(id, userId);
    }
    create(createNotificationDto) {
        return this.notificationsService.create(createNotificationDto);
    }
    update(id, updateNotificationDto, userId) {
        return this.notificationsService.update(id, updateNotificationDto, userId);
    }
    delete(id, userId) {
        return this.notificationsService.delete(id, userId);
    }
    markAsRead(id, userId) {
        return this.notificationsService.markAsRead(id, userId);
    }
    findUnread(userId) {
        return this.notificationsService.findUnread(userId);
    }
    async registerDeviceToken(dto, req) {
        const userId = req.user?.uid;
        if (!userId) {
            throw new common_1.UnauthorizedException('User not authenticated');
        }
        return await this.pushNotificationService.registerDeviceToken(userId, dto.token, dto.platform);
    }
    async removeDeviceToken(dto, req) {
        const userId = req.user?.uid;
        if (!userId) {
            throw new common_1.UnauthorizedException('User not authenticated');
        }
        await this.pushNotificationService.removeDeviceToken(userId, dto.token);
        return { message: 'Device token removed successfully' };
    }
    async testPushNotification(dto, req) {
        const userId = req.user?.uid;
        if (!userId) {
            throw new common_1.UnauthorizedException('User not authenticated');
        }
        const user = await this.prisma.user.findUnique({
            where: { firebaseUid: userId },
        });
        if (!user || user.role !== 'ADMIN') {
            throw new common_1.UnauthorizedException('Only admins can send test notifications');
        }
        return await this.pushNotificationService.sendPushNotification(dto.userId, dto.title, dto.body, dto.data);
    }
    async getNotificationHistory(userId, req) {
        const authUserId = req.user?.uid;
        if (!authUserId) {
            throw new common_1.UnauthorizedException('User not authenticated');
        }
        const user = await this.prisma.user.findUnique({
            where: { firebaseUid: authUserId },
        });
        if (!user || (user.id !== userId && user.role !== 'ADMIN')) {
            throw new common_1.UnauthorizedException('You can only access your own notification history');
        }
        return await this.prisma.notificationLog.findMany({
            where: { userId },
            orderBy: { sentAt: 'desc' },
            take: 50,
        });
    }
    async getNotificationPreferences(userId, req) {
        const authUserId = req.user?.uid;
        if (!authUserId) {
            throw new common_1.UnauthorizedException('User not authenticated');
        }
        const user = await this.prisma.user.findUnique({
            where: { firebaseUid: authUserId },
        });
        if (!user || user.id !== userId) {
            throw new common_1.UnauthorizedException('You can only access your own preferences');
        }
        return await this.prisma.notificationPreference.findMany({
            where: { userId },
        });
    }
    async updateNotificationPreference(userId, dto, req) {
        const authUserId = req.user?.uid;
        if (!authUserId) {
            throw new common_1.UnauthorizedException('User not authenticated');
        }
        const user = await this.prisma.user.findUnique({
            where: { firebaseUid: authUserId },
        });
        if (!user || user.id !== userId) {
            throw new common_1.UnauthorizedException('You can only update your own preferences');
        }
        return await this.prisma.notificationPreference.upsert({
            where: {
                userId_notificationType: {
                    userId,
                    notificationType: dto.notificationType,
                },
            },
            update: {
                pushEnabled: dto.pushEnabled ?? undefined,
                emailEnabled: dto.emailEnabled ?? undefined,
            },
            create: {
                userId,
                notificationType: dto.notificationType,
                pushEnabled: dto.pushEnabled ?? true,
                emailEnabled: dto.emailEnabled ?? true,
            },
        });
    }
    async unsubscribeFromEmails(token) {
        try {
            const userId = Buffer.from(token, 'base64').toString('utf-8');
            await this.prisma.notificationPreference.updateMany({
                where: { userId },
                data: { emailEnabled: false },
            });
            return {
                message: 'Successfully unsubscribed from email notifications. You can manage your preferences in the app settings.',
            };
        }
        catch (error) {
            throw new common_1.BadRequestException('Invalid unsubscribe token');
        }
    }
};
exports.NotificationsController = NotificationsController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], NotificationsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Query)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], NotificationsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_notification_dto_1.CreateNotificationDto]),
    __metadata("design:returntype", void 0)
], NotificationsController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Query)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_notification_dto_1.UpdateNotificationDto, String]),
    __metadata("design:returntype", void 0)
], NotificationsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Query)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], NotificationsController.prototype, "delete", null);
__decorate([
    (0, common_1.Put)(':id/read'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Query)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], NotificationsController.prototype, "markAsRead", null);
__decorate([
    (0, common_1.Get)('unread'),
    __param(0, (0, common_1.Query)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], NotificationsController.prototype, "findUnread", null);
__decorate([
    (0, common_1.Post)('register-token'),
    (0, common_1.HttpCode)(common_1.HttpStatus.CREATED),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [register_device_token_dto_1.RegisterDeviceTokenDto, Object]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "registerDeviceToken", null);
__decorate([
    (0, common_1.Post)('remove-token'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [remove_device_token_dto_1.RemoveDeviceTokenDto, Object]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "removeDeviceToken", null);
__decorate([
    (0, common_1.Post)('test-push'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [test_push_notification_dto_1.TestPushNotificationDto, Object]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "testPushNotification", null);
__decorate([
    (0, common_1.Get)('history/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "getNotificationHistory", null);
__decorate([
    (0, common_1.Get)('preferences/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "getNotificationPreferences", null);
__decorate([
    (0, common_1.Put)('preferences/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_notification_preference_dto_1.UpdateNotificationPreferenceDto, Object]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "updateNotificationPreference", null);
__decorate([
    (0, common_1.Get)('unsubscribe/:token'),
    __param(0, (0, common_1.Param)('token')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "unsubscribeFromEmails", null);
exports.NotificationsController = NotificationsController = __decorate([
    (0, common_1.Controller)('notifications'),
    (0, common_1.UseGuards)(firebase_auth_guard_1.FirebaseAuthGuard),
    __metadata("design:paramtypes", [notifications_service_1.NotificationsService,
        push_notification_service_1.PushNotificationService,
        prisma_service_1.PrismaService])
], NotificationsController);
//# sourceMappingURL=notifications.controller.js.map