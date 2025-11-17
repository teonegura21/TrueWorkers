import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  AttachmentEntity,
  AttachmentStatus,
  Conversation,
  ConversationParticipant,
  ConversationParticipantRole,
  ConversationType,
  Message,
  MessageKind,
  RetentionPolicy,
  User,
  UserRole,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendConversationMessageDto } from './dto/send-conversation-message.dto';
import { ListConversationMessagesDto } from './dto/list-conversation-messages.dto';

const SUPPORT_POLICY_CODE = 'SUPPORT_THREAD';

type ConversationWithRelations = Conversation & {
  participants: (ConversationParticipant & {
    user?: Pick<User, 'id' | 'fullName' | 'profileImage' | 'role'>;
  })[];
  project: {
    id: string;
    title: string | null;
    status: string;
  } | null;
};

type MessageWithRelations = Message & {
  sender?: Pick<User, 'id' | 'fullName' | 'profileImage'>;
  attachments: {
    attachment: {
      id: string;
      bucket: string;
      objectPath: string;
      contentType: string;
      fileSize: number;
      status: AttachmentStatus;
    };
  }[];
};

@Injectable()
export class ConversationsService {
  constructor(private readonly prisma: PrismaService) {}

  async listForUser(userId: string) {
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

    const summaries = await Promise.all(
      membershipRows.map(async (membership) => {
        const conversation =
          membership.conversation as ConversationWithRelations;
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
          this.computeUnreadCount(
            conversation.id,
            membership.userId,
            membership.lastReadMessageId,
          ),
        ]);

        const lastMessage = lastMessages.length
          ? this.mapMessage(lastMessages[0] as MessageWithRelations)
          : null;
        return this.mapConversation(conversation, { unreadCount, lastMessage });
      }),
    );

    return summaries;
  }

  async createConversation(dto: CreateConversationDto, creatorId: string) {
    const participantIds = Array.from(
      new Set([creatorId, ...(dto.participantIds || [])]),
    );
    if (participantIds.length < 2) {
      throw new ForbiddenException(
        'A conversation requires at least two participants.',
      );
    }

    const retentionPolicy =
      await this.ensureRetentionPolicy(SUPPORT_POLICY_CODE);
    const participants = await this.prisma.user.findMany({
      where: { id: { in: participantIds } },
      select: { id: true, role: true },
    });
    if (participants.length !== participantIds.length) {
      throw new NotFoundException(
        'One or more participants could not be found.',
      );
    }

    let projectConnect: { id: string } | undefined;
    if (dto.projectId) {
      const project = await this.prisma.project.findUnique({
        where: { id: dto.projectId },
      });
      if (!project) throw new NotFoundException('Project not found');
      if (
        !participantIds.includes(project.clientId) ||
        (project.craftsmanId && !participantIds.includes(project.craftsmanId))
      ) {
        throw new ForbiddenException(
          'Project conversations must include client and craftsman.',
        );
      }
      projectConnect = { id: project.id };
    }

    // Create conversation first without projectId to avoid XOR constraint
    const conversationData: any = {
      title: dto.title,
      type: dto.projectId
        ? ConversationType.PROJECT
        : ConversationType.SUPPORT,
      retentionPolicyId: retentionPolicy.id,
    };
    
    if (projectConnect?.id) {
      conversationData.projectId = projectConnect.id;
    }

    const conversation = await this.prisma.conversation.create({
      data: conversationData,
    });

    // Create participants separately
    await this.prisma.conversationParticipant.createMany({
      data: participants.map((participant) => ({
        conversationId: conversation.id,
        userId: participant.id,
        role: this.mapRole(participant.role, !!dto.projectId),
      })),
    });

    // Fetch the complete conversation with relations
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

    return this.mapConversation(completeConversation as ConversationWithRelations, {
      unreadCount: 0,
      lastMessage: null,
    });
  }

  async ensureProjectConversation(projectId: string, userId: string) {
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
    });
    if (!project) throw new NotFoundException('Project not found');
    if (![project.clientId, project.craftsmanId].filter(Boolean).includes(userId)) {
      throw new ForbiddenException(
        'You do not have access to this project conversation.',
      );
    }

    const existing = await this.prisma.conversation.findFirst({
      where: { projectId, type: ConversationType.PROJECT },
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
        ? this.mapMessage(lastMessageRecord as MessageWithRelations)
        : null;
      return this.mapConversation(existing as ConversationWithRelations, {
        unreadCount,
        lastMessage,
      });
    }

    return this.createConversation(
      {
        projectId,
        participantIds: [project.clientId, project.craftsmanId].filter(Boolean) as string[],
      },
      userId,
    );
  }

  async sendMessage(senderId: string, dto: SendConversationMessageDto) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: dto.conversationId },
      include: { participants: true },
    });
    if (!conversation) throw new NotFoundException('Conversation not found');

    const participant = conversation.participants.find(
      (p) => p.userId === senderId,
    );
    if (!participant)
      throw new ForbiddenException(
        'You are not a participant in this conversation.',
      );

    if (!dto.body && (!dto.attachmentIds || dto.attachmentIds.length === 0)) {
      throw new ForbiddenException('Message must include text or attachments.');
    }

    const message = await this.prisma.message.create({
      data: {
        conversationId: conversation.id,
        senderId,
        kind: dto.kind ?? MessageKind.TEXT,
        body: dto.body,
        retentionPolicyId: conversation.retentionPolicyId,
      },
    });

    if (dto.attachmentIds?.length) {
      const attachments = await this.prisma.attachment.findMany({
        where: { id: { in: dto.attachmentIds } },
      });
      if (attachments.length !== dto.attachmentIds.length) {
        throw new NotFoundException('One or more attachments were not found');
      }
      await this.prisma.attachmentLink.createMany({
        data: attachments.map((attachment) => ({
          attachmentId: attachment.id,
          entityType: AttachmentEntity.MESSAGE,
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

  async listMessages(userId: string, query: ListConversationMessagesDto) {
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
      throw new NotFoundException('Conversation not found');
    }

    const items = messages
      .map((message) => this.mapMessage(message as MessageWithRelations))
      .reverse();
    const lastMessage = items.length ? items[items.length - 1] : null;

    return {
      conversation: this.mapConversation(
        conversation as ConversationWithRelations,
        {
          unreadCount,
          lastMessage,
        },
      ),
      items,
      meta: {
        total,
        skip,
        take,
      },
    };
  }

  async markConversationRead(
    conversationId: string,
    userId: string,
    messageId?: string,
  ) {
    await this.ensureParticipant(conversationId, userId);
    let finalMessageId = messageId;
    if (!finalMessageId) {
      const latest = await this.prisma.message.findFirst({
        where: { conversationId },
        orderBy: { sentAt: 'desc' },
        select: { id: true },
      });
      if (!latest) return;
      finalMessageId = latest.id;
    }
    await this.prisma.conversationParticipant.update({
      where: { conversationId_userId: { conversationId, userId } },
      data: { lastReadMessageId: finalMessageId },
    });
  }

  async getUnreadCount(conversationId: string, userId: string) {
    await this.ensureParticipant(conversationId, userId);
    return this.computeUnreadCount(conversationId, userId);
  }

  private async ensureParticipant(conversationId: string, userId: string) {
    const participant = await this.prisma.conversationParticipant.findUnique({
      where: { conversationId_userId: { conversationId, userId } },
    });
    if (!participant)
      throw new ForbiddenException(
        'You are not a participant in this conversation.',
      );
    return participant;
  }

  private async ensureRetentionPolicy(code: string): Promise<RetentionPolicy> {
    const policy = await this.prisma.retentionPolicy.findUnique({
      where: { code },
    });
    if (!policy) {
      throw new NotFoundException(
        `Retention policy ${code} was not found. Please seed the database.`,
      );
    }
    return policy;
  }

  private mapRole(
    role: UserRole,
    isProjectConversation: boolean,
  ): ConversationParticipantRole {
    if (isProjectConversation) {
      switch (role) {
        case UserRole.CLIENT:
          return ConversationParticipantRole.CLIENT;
        case UserRole.CRAFTSMAN:
          return ConversationParticipantRole.MESTER;
        default:
          return ConversationParticipantRole.SUPPORT;
      }
    }
    switch (role) {
      case UserRole.CLIENT:
        return ConversationParticipantRole.CLIENT;
      case UserRole.CRAFTSMAN:
        return ConversationParticipantRole.MESTER;
      case UserRole.ADMIN:
      default:
        return ConversationParticipantRole.SUPPORT;
    }
  }

  private mapConversation(
    conversation: ConversationWithRelations,
    options: {
      unreadCount: number;
      lastMessage: ReturnType<typeof this.mapMessage> | null;
    },
  ) {
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

    const lastActivity =
      options.lastMessage?.sentAt ??
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

  private mapMessage(message: MessageWithRelations) {
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

  private async computeUnreadCount(
    conversationId: string,
    userId: string,
    lastReadMessageId?: string | null,
  ) {
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

  private async fetchMessageWithRelations(messageId: string) {
    const message = await this.prisma.message.findUnique({
      where: { id: messageId },
      include: {
        sender: { select: { id: true, fullName: true, profileImage: true } },
        attachments: { include: { attachment: true } },
      },
    });
    if (!message) {
      throw new NotFoundException('Message not found after creation');
    }
    return message as MessageWithRelations;
  }
}
