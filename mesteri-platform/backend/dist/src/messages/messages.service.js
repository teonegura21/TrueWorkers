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
var MessagesService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.MessagesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let MessagesService = MessagesService_1 = class MessagesService {
    prisma;
    logger = new common_1.Logger(MessagesService_1.name);
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(createMessageDto, senderId) {
        const [sender, project] = await Promise.all([
            this.prisma.user.findUnique({ where: { id: senderId } }),
            this.prisma.project.findUnique({
                where: { id: createMessageDto.projectId },
                include: { job: true },
            }),
        ]);
        if (!sender)
            throw new common_1.NotFoundException('Sender not found');
        if (!project)
            throw new common_1.NotFoundException('Project not found');
        if (project.clientId !== senderId && project.craftsmanId !== senderId) {
            throw new common_1.ForbiddenException('Users must be project client or craftsman to communicate');
        }
        const created = await this.prisma.message.create({
            data: {
                body: createMessageDto.content,
                conversationId: "default-conversation-id",
                retentionPolicyId: "default-retention-policy-id",
            },
        });
        this.logger.log(`Message created: ${created.id} for project ${project.id}`);
        return created;
    }
    async findAllByProject(projectId, userId, options) {
        await this.validateProjectAccess(projectId, userId);
        const project = await this.prisma.project.findUnique({
            where: { id: projectId },
        });
        if (!project)
            throw new common_1.NotFoundException('Project not found');
        const { skip = 0, take = 50 } = options || {};
        return this.prisma.message.findMany({
            where: { jobId: project.jobId },
            orderBy: { createdAt: 'asc' },
            skip,
            take,
        });
    }
    async findOne(id, userId) {
        const message = await this.prisma.message.findUnique({ where: { id } });
        if (!message) {
            throw new common_1.NotFoundException('Message not found');
        }
        if (message.jobId) {
            const project = await this.prisma.project.findFirst({
                where: { jobId: message.jobId },
            });
            if (!project)
                throw new common_1.NotFoundException('Related project not found');
            await this.validateProjectAccess(project.id, userId);
        }
        return message;
    }
    async update(id, updateMessageDto, userId) {
        const message = await this.findOne(id, userId);
        if (updateMessageDto.isRead !== undefined && message.senderId !== userId) {
            if (message.jobId) {
                const project = await this.prisma.project.findFirst({
                    where: { jobId: message.jobId },
                });
                if (!project ||
                    (project.clientId !== userId && project.craftsmanId !== userId)) {
                    throw new common_1.ForbiddenException('You do not have access to update this message');
                }
            }
        }
        await this.prisma.message.update({
            where: { id },
            data: { body: message.body },
        });
        return (await this.prisma.message.findUnique({
            where: { id },
        }));
    }
    async markAllAsRead(projectId, userId) {
        await this.validateProjectAccess(projectId, userId);
        const project = await this.prisma.project.findUnique({
            where: { id: projectId },
        });
        if (!project)
            throw new common_1.NotFoundException('Project not found');
        const updated = await this.prisma.message.updateMany({
            where: { jobId: project.jobId },
            data: { editedAt: new Date() },
        });
        return updated.count || 0;
    }
    async remove(id, userId) {
        const message = await this.findOne(id, userId);
        if (message.senderId !== userId) {
            throw new common_1.ForbiddenException('Only message sender can delete messages');
        }
        await this.prisma.message.delete({ where: { id } });
    }
    async getUnreadCount(projectId, userId) {
        await this.validateProjectAccess(projectId, userId);
        const project = await this.prisma.project.findUnique({
            where: { id: projectId },
        });
        if (!project)
            throw new common_1.NotFoundException('Project not found');
        const count = await this.prisma.message.count({
            where: { jobId: project.jobId },
        });
        return count || 0;
    }
    async createSystemMessage(projectId, systemType, extraContent) {
        const project = await this.prisma.project.findUnique({
            where: { id: projectId },
            include: { job: true },
        });
        if (!project) {
            throw new common_1.NotFoundException('Project not found');
        }
        let content = '';
        switch (systemType) {
            case 'PROJECT_STARTED':
                content = `Project "${project.job?.title || 'Project'}" has started`;
                break;
            case 'MILESTONE_COMPLETED':
                content = extraContent || 'A milestone has been completed';
                break;
            case 'PAYMENT_SENT':
                content = extraContent || 'A payment has been sent';
                break;
            case 'PROJECT_COMPLETED':
                content = `Project "${project.job?.title || 'Project'}" has been completed`;
                break;
            case 'REVIEW_SUBMITTED':
                content = extraContent || 'A review has been submitted';
                break;
        }
        const systemMessage = await this.prisma.message.create({
            data: {
                body: content,
                conversationId: "default-conversation-id",
                retentionPolicyId: "default-retention-policy-id",
                senderId: project.clientId,
                jobId: project.jobId,
            },
        });
        return systemMessage;
    }
    async searchMessages(projectId, userId, query, options) {
        await this.validateProjectAccess(projectId, userId);
        const project = await this.prisma.project.findUnique({
            where: { id: projectId },
        });
        if (!project)
            throw new common_1.NotFoundException('Project not found');
        const { skip = 0, take = 20 } = options || {};
        return this.prisma.message.findMany({
            where: {
                jobId: project.jobId,
                body: { contains: query, mode: 'insensitive' },
            },
            orderBy: { createdAt: 'desc' },
            skip,
            take,
        });
    }
    async validateProjectAccess(projectId, userId) {
        const project = await this.prisma.project.findUnique({
            where: { id: projectId },
        });
        if (!project) {
            throw new common_1.NotFoundException('Project not found');
        }
        const isClient = project.clientId === userId;
        const isCraftsman = project.craftsmanId === userId;
        if (!isClient && !isCraftsman) {
            throw new common_1.ForbiddenException('You do not have access to this project chat');
        }
    }
    async getConversationHistory(projectId, userId, options) {
        await this.validateProjectAccess(projectId, userId);
        const { before, after, limit = 50 } = options || {};
        const project = await this.prisma.project.findUnique({
            where: { id: projectId },
        });
        if (!project)
            throw new common_1.NotFoundException('Project not found');
        const where = { jobId: project.jobId };
        if (before)
            where.createdAt = { lt: before };
        if (after)
            where.createdAt = { gt: after };
        const messages = await this.prisma.message.findMany({
            where,
            orderBy: { createdAt: 'desc' },
            take: limit + 1,
        });
        const hasMore = messages.length > limit;
        const sliced = hasMore ? messages.slice(0, limit) : messages;
        const total = await this.prisma.message.count({
            where: { jobId: project.jobId },
        });
        return { messages: sliced.reverse(), total, hasMore };
    }
};
exports.MessagesService = MessagesService;
exports.MessagesService = MessagesService = MessagesService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], MessagesService);
//# sourceMappingURL=messages.service.js.map