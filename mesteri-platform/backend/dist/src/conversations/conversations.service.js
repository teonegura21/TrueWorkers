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
exports.ConversationsService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const prisma_service_1 = require("../prisma/prisma.service");
const SUPPORT_POLICY_CODE = 'SUPPORT_THREAD';
let ConversationsService = class ConversationsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async listForUser(userId) {
        const membershipRows = await this.prisma.conversationParticipant.findMany({
            where: { userId },
            include: {
                conversation: {
                    include: {
                        project: { select: { id: true, title: true, status: true } },
                        participants: {
                            include: {
                                user: {
                                    select: {
                                        id: true,
                                        fullName: true,
                                        profileImage: true,
                                        role: true,
                                    },
                                },
                            },
                        },
                    },
                },
            },
            orderBy: { conversation: { updatedAt: 'desc' } },
        });
        const summaries = await Promise.all(membershipRows.map(async (membership) => {
            const conversation = membership.conversation;
            const [lastMessages, unreadCount] = await Promise.all([
                this.prisma.message.findMany({
                    where: { conversationId: conversation.id },
                    orderBy: { sentAt: 'desc' },
                    take: 1,
                    include: {
                        sender: {
                            select: { id: true, fullName: true, profileImage: true },
                        },
                        attachments: { include: { attachment: true } },
                    },
                }),
                this.computeUnreadCount(conversation.id, membership.userId, membership.lastReadMessageId),
            ]);
            const lastMessage = lastMessages.length
                ? this.mapMessage(lastMessages[0])
                : null;
            return this.mapConversation(conversation, { unreadCount, lastMessage });
        }));
        return summaries;
    }
    async createConversation(dto, creatorId) {
        const participantIds = Array.from(new Set([creatorId, ...(dto.participantIds || [])]));
        if (participantIds.length < 2) {
            throw new common_1.ForbiddenException('A conversation requires at least two participants.');
        }
        const retentionPolicy = await this.ensureRetentionPolicy(SUPPORT_POLICY_CODE);
        const participants = await this.prisma.user.findMany({
            where: { id: { in: participantIds } },
            select: { id: true, role: true },
        });
        if (participants.length !== participantIds.length) {
            throw new common_1.NotFoundException('One or more participants could not be found.');
        }
        let projectConnect;
        if (dto.projectId) {
            const project = await this.prisma.project.findUnique({
                where: { id: dto.projectId },
            });
            if (!project)
                throw new common_1.NotFoundException('Project not found');
            if (!participantIds.includes(project.clientId) ||
                (project.craftsmanId && !participantIds.includes(project.craftsmanId))) {
                throw new common_1.ForbiddenException('Project conversations must include client and craftsman.');
            }
            projectConnect = { id: project.id };
        }
        const conversationData = {
            title: dto.title,
            type: dto.projectId
                ? client_1.ConversationType.PROJECT
                : client_1.ConversationType.SUPPORT,
            retentionPolicyId: retentionPolicy.id,
        };
        if (projectConnect?.id) {
            conversationData.projectId = projectConnect.id;
        }
        const conversation = await this.prisma.conversation.create({
            data: conversationData,
        });
        await this.prisma.conversationParticipant.createMany({
            data: participants.map((participant) => ({
                conversationId: conversation.id,
                userId: participant.id,
                role: this.mapRole(participant.role, !!dto.projectId),
            })),
        });
        const completeConversation = await this.prisma.conversation.findUnique({
            where: { id: conversation.id },
            include: {
                project: { select: { id: true, title: true, status: true } },
                participants: {
                    include: {
                        user: {
                            select: {
                                id: true,
                                fullName: true,
                                profileImage: true,
                                role: true,
                            },
                        },
                    },
                },
            },
        });
        if (dto.projectId) {
            await this.prisma.project.update({
                where: { id: dto.projectId },
                data: { primaryConversationId: conversation.id },
            });
        }
        return this.mapConversation(completeConversation, {
            unreadCount: 0,
            lastMessage: null,
        });
    }
    async ensureProjectConversation(projectId, userId) {
        const project = await this.prisma.project.findUnique({
            where: { id: projectId },
        });
        if (!project)
            throw new common_1.NotFoundException('Project not found');
        if (![project.clientId, project.craftsmanId].filter(Boolean).includes(userId)) {
            throw new common_1.ForbiddenException('You do not have access to this project conversation.');
        }
        const existing = await this.prisma.conversation.findFirst({
            where: { projectId, type: client_1.ConversationType.PROJECT },
            include: {
                project: { select: { id: true, title: true, status: true } },
                participants: {
                    include: {
                        user: {
                            select: {
                                id: true,
                                fullName: true,
                                profileImage: true,
                                role: true,
                            },
                        },
                    },
                },
            },
        });
        if (existing) {
            const unreadCount = await this.computeUnreadCount(existing.id, userId);
            const lastMessageRecord = await this.prisma.message.findFirst({
                where: { conversationId: existing.id },
                orderBy: { sentAt: 'desc' },
                include: {
                    sender: { select: { id: true, fullName: true, profileImage: true } },
                    attachments: { include: { attachment: true } },
                },
            });
            const lastMessage = lastMessageRecord
                ? this.mapMessage(lastMessageRecord)
                : null;
            return this.mapConversation(existing, {
                unreadCount,
                lastMessage,
            });
        }
        return this.createConversation({
            projectId,
            participantIds: [project.clientId, project.craftsmanId].filter(Boolean),
        }, userId);
    }
    async sendMessage(senderId, dto) {
        const conversation = await this.prisma.conversation.findUnique({
            where: { id: dto.conversationId },
            include: { participants: true },
        });
        if (!conversation)
            throw new common_1.NotFoundException('Conversation not found');
        const participant = conversation.participants.find((p) => p.userId === senderId);
        if (!participant)
            throw new common_1.ForbiddenException('You are not a participant in this conversation.');
        if (!dto.body && (!dto.attachmentIds || dto.attachmentIds.length === 0)) {
            throw new common_1.ForbiddenException('Message must include text or attachments.');
        }
        const message = await this.prisma.message.create({
            data: {
                conversationId: conversation.id,
                senderId,
                kind: dto.kind ?? client_1.MessageKind.TEXT,
                body: dto.body,
                retentionPolicyId: conversation.retentionPolicyId,
            },
        });
        if (dto.attachmentIds?.length) {
            const attachments = await this.prisma.attachment.findMany({
                where: { id: { in: dto.attachmentIds } },
            });
            if (attachments.length !== dto.attachmentIds.length) {
                throw new common_1.NotFoundException('One or more attachments were not found');
            }
            await this.prisma.attachmentLink.createMany({
                data: attachments.map((attachment) => ({
                    attachmentId: attachment.id,
                    entityType: client_1.AttachmentEntity.MESSAGE,
                    entityId: message.id,
                })),
            });
        }
        await this.prisma.conversation.update({
            where: { id: dto.conversationId },
            data: { updatedAt: message.sentAt },
        });
        await this.prisma.conversationParticipant.update({
            where: {
                conversationId_userId: {
                    conversationId: conversation.id,
                    userId: senderId,
                },
            },
            data: { lastReadMessageId: message.id },
        });
        if (conversation.projectId && senderId === conversation.createdById) {
            await this.prisma.project.update({
                where: { id: conversation.projectId },
                data: { primaryConversationId: conversation.id },
            });
        }
        const fullMessage = await this.fetchMessageWithRelations(message.id);
        return this.mapMessage(fullMessage);
    }
    async listMessages(userId, query) {
        await this.ensureParticipant(query.conversationId, userId);
        const { skip = 0, take = 50 } = query;
        const [conversation, messages, total, unreadCount] = await Promise.all([
            this.prisma.conversation.findUnique({
                where: { id: query.conversationId },
                include: {
                    project: { select: { id: true, title: true, status: true } },
                    participants: {
                        include: {
                            user: {
                                select: {
                                    id: true,
                                    fullName: true,
                                    profileImage: true,
                                    role: true,
                                },
                            },
                        },
                    },
                },
            }),
            this.prisma.message.findMany({
                where: { conversationId: query.conversationId },
                orderBy: { sentAt: 'desc' },
                skip,
                take,
                include: {
                    sender: { select: { id: true, fullName: true, profileImage: true } },
                    attachments: { include: { attachment: true } },
                },
            }),
            this.prisma.message.count({
                where: { conversationId: query.conversationId },
            }),
            this.computeUnreadCount(query.conversationId, userId),
        ]);
        if (!conversation) {
            throw new common_1.NotFoundException('Conversation not found');
        }
        const items = messages
            .map((message) => this.mapMessage(message))
            .reverse();
        const lastMessage = items.length ? items[items.length - 1] : null;
        return {
            conversation: this.mapConversation(conversation, {
                unreadCount,
                lastMessage,
            }),
            items,
            meta: {
                total,
                skip,
                take,
            },
        };
    }
    async markConversationRead(conversationId, userId, messageId) {
        await this.ensureParticipant(conversationId, userId);
        let finalMessageId = messageId;
        if (!finalMessageId) {
            const latest = await this.prisma.message.findFirst({
                where: { conversationId },
                orderBy: { sentAt: 'desc' },
                select: { id: true },
            });
            if (!latest)
                return;
            finalMessageId = latest.id;
        }
        await this.prisma.conversationParticipant.update({
            where: { conversationId_userId: { conversationId, userId } },
            data: { lastReadMessageId: finalMessageId },
        });
    }
    async getUnreadCount(conversationId, userId) {
        await this.ensureParticipant(conversationId, userId);
        return this.computeUnreadCount(conversationId, userId);
    }
    async ensureParticipant(conversationId, userId) {
        const participant = await this.prisma.conversationParticipant.findUnique({
            where: { conversationId_userId: { conversationId, userId } },
        });
        if (!participant)
            throw new common_1.ForbiddenException('You are not a participant in this conversation.');
        return participant;
    }
    async ensureRetentionPolicy(code) {
        const policy = await this.prisma.retentionPolicy.findUnique({
            where: { code },
        });
        if (!policy) {
            throw new common_1.NotFoundException(`Retention policy ${code} was not found. Please seed the database.`);
        }
        return policy;
    }
    mapRole(role, isProjectConversation) {
        if (isProjectConversation) {
            switch (role) {
                case client_1.UserRole.CLIENT:
                    return client_1.ConversationParticipantRole.CLIENT;
                case client_1.UserRole.CRAFTSMAN:
                    return client_1.ConversationParticipantRole.MESTER;
                default:
                    return client_1.ConversationParticipantRole.SUPPORT;
            }
        }
        switch (role) {
            case client_1.UserRole.CLIENT:
                return client_1.ConversationParticipantRole.CLIENT;
            case client_1.UserRole.CRAFTSMAN:
                return client_1.ConversationParticipantRole.MESTER;
            case client_1.UserRole.ADMIN:
            default:
                return client_1.ConversationParticipantRole.SUPPORT;
        }
    }
    mapConversation(conversation, options) {
        const project = conversation.project
            ? {
                id: conversation.project.id,
                title: conversation.project.title,
                status: conversation.project.status,
            }
            : null;
        const participants = conversation.participants.map((participant) => ({
            id: participant.userId,
            role: participant.role,
            name: participant.user?.fullName ?? '',
            avatarUrl: participant.user?.profileImage,
        }));
        const lastActivity = options.lastMessage?.sentAt ??
            conversation.updatedAt ??
            conversation.createdAt;
        const isActive = project ? project.status === 'ACTIVE' : true;
        return {
            id: conversation.id,
            title: conversation.title ?? project?.title ?? 'Conversa?ie',
            type: conversation.type,
            project,
            participants,
            unreadCount: options.unreadCount,
            lastMessage: options.lastMessage,
            updatedAt: lastActivity,
            isActive,
        };
    }
    mapMessage(message) {
        return {
            id: message.id,
            kind: message.kind,
            body: message.body,
            sentAt: message.sentAt,
            editedAt: message.editedAt,
            sender: message.sender
                ? {
                    id: message.sender.id,
                    name: message.sender.fullName,
                    avatarUrl: message.sender.profileImage,
                }
                : null,
            attachments: message.attachments.map((link) => ({
                id: link.attachment.id,
                bucket: link.attachment.bucket,
                objectPath: link.attachment.objectPath,
                contentType: link.attachment.contentType,
                fileSize: link.attachment.fileSize,
                status: link.attachment.status,
            })),
        };
    }
    async computeUnreadCount(conversationId, userId, lastReadMessageId) {
        if (!lastReadMessageId) {
            return this.prisma.message.count({ where: { conversationId } });
        }
        const lastRead = await this.prisma.message.findUnique({
            where: { id: lastReadMessageId },
            select: { sentAt: true },
        });
        if (!lastRead) {
            return this.prisma.message.count({ where: { conversationId } });
        }
        const count = await this.prisma.message.count({
            where: {
                conversationId,
                sentAt: { gt: lastRead.sentAt },
            },
        });
        return count;
    }
    async fetchMessageWithRelations(messageId) {
        const message = await this.prisma.message.findUnique({
            where: { id: messageId },
            include: {
                sender: { select: { id: true, fullName: true, profileImage: true } },
                attachments: { include: { attachment: true } },
            },
        });
        if (!message) {
            throw new common_1.NotFoundException('Message not found after creation');
        }
        return message;
    }
};
exports.ConversationsService = ConversationsService;
exports.ConversationsService = ConversationsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ConversationsService);
//# sourceMappingURL=conversations.service.js.map