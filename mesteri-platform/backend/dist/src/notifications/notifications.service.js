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
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let NotificationsService = class NotificationsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll(userId) {
        const where = userId ? { userId } : {};
        return this.prisma.notification.findMany({
            where,
            include: {
                user: true,
                job: true,
            },
            orderBy: { createdAt: 'desc' },
        });
    }
    async findOne(id, userId) {
        const where = userId ? { id, userId } : { id };
        const notification = await this.prisma.notification.findFirst({
            where,
            include: {
                user: true,
                job: true,
            },
        });
        if (!notification) {
            throw new common_1.NotFoundException(`Notification with ID ${id} not found`);
        }
        return notification;
    }
    async create(createNotificationDto) {
        return this.prisma.notification.create({
            data: createNotificationDto,
            include: {
                user: true,
                job: true,
            },
        });
    }
    async update(id, updateNotificationDto, userId) {
        try {
            return await this.prisma.notification.update({
                where: { id },
                data: updateNotificationDto,
                include: {
                    user: true,
                    job: true,
                },
            });
        }
        catch (error) {
            if (error.code === 'P2025') {
                throw new common_1.NotFoundException(`Notification with ID ${id} not found`);
            }
            throw error;
        }
    }
    async delete(id, userId) {
        try {
            await this.prisma.notification.delete({ where: { id } });
        }
        catch (error) {
            if (error.code === 'P2025') {
                throw new common_1.NotFoundException(`Notification with ID ${id} not found`);
            }
            throw error;
        }
    }
    async markAsRead(id, userId) {
        return this.update(id, { isRead: true }, userId);
    }
    async findUnread(userId) {
        return this.findAll(userId).then((notifications) => notifications.filter((n) => !n.isRead));
    }
};
exports.NotificationsService = NotificationsService;
exports.NotificationsService = NotificationsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], NotificationsService);
//# sourceMappingURL=notifications.service.js.map