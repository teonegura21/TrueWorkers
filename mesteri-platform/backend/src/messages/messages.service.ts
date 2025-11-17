import {
  Injectable,
  ForbiddenException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Message as PrismaMessage } from '@prisma/client';
import { CreateMessageDto } from './dto/create-message.dto';
import { UpdateMessageDto } from './dto/update-message.dto';

@Injectable()
export class MessagesService {
  private readonly logger = new Logger(MessagesService.name);

  constructor(private readonly prisma: PrismaService) {}

  // Note: Prisma Message has no receiverId/projectId; we map by project's jobId
  async create(
    createMessageDto: CreateMessageDto,
    senderId: string,
  ): Promise<PrismaMessage> {
    const [sender, project] = await Promise.all([
      this.prisma.user.findUnique({ where: { id: senderId } }),
      this.prisma.project.findUnique({
        where: { id: createMessageDto.projectId },
        include: { job: true },
      }),
    ]);
    if (!sender) throw new NotFoundException('Sender not found');
    if (!project) throw new NotFoundException('Project not found');

    // Ensure sender is part of project
    if (project.clientId !== senderId && project.craftsmanId !== senderId) {
      throw new ForbiddenException(
        'Users must be project client or craftsman to communicate',
      );
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

  async findAllByProject(
    projectId: string,
    userId: string,
    options?: { skip?: number; take?: number },
  ): Promise<PrismaMessage[]> {
    await this.validateProjectAccess(projectId, userId);
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
    });
    if (!project) throw new NotFoundException('Project not found');
    const { skip = 0, take = 50 } = options || {};
    return this.prisma.message.findMany({
      where: { jobId: project.jobId },
      orderBy: { createdAt: 'asc' },
      skip,
      take,
    });
  }

  async findOne(id: string, userId: string): Promise<PrismaMessage> {
    const message = await this.prisma.message.findUnique({ where: { id } });

    if (!message) {
      throw new NotFoundException('Message not found');
    }

    // Validate access via job->project mapping
    if (message.jobId) {
      const project = await this.prisma.project.findFirst({
        where: { jobId: message.jobId },
      });
      if (!project) throw new NotFoundException('Related project not found');
      await this.validateProjectAccess(project.id, userId);
    }

    return message;
  }

  async update(
    id: string,
    updateMessageDto: UpdateMessageDto,
    userId: string,
  ): Promise<PrismaMessage> {
    const message = await this.findOne(id, userId);
    // Without receiverId, allow sender or project members
    if (updateMessageDto.isRead !== undefined && message.senderId !== userId) {
      if (message.jobId) {
        const project = await this.prisma.project.findFirst({
          where: { jobId: message.jobId },
        });
        if (
          !project ||
          (project.clientId !== userId && project.craftsmanId !== userId)
        ) {
          throw new ForbiddenException(
            'You do not have access to update this message',
          );
        }
      }
    }
    await this.prisma.message.update({
      where: { id },
      data: { body: message.body },
    });
    return (await this.prisma.message.findUnique({
      where: { id },
    })) as PrismaMessage;
  }

  async markAllAsRead(projectId: string, userId: string): Promise<number> {
    // Validate project access
    await this.validateProjectAccess(projectId, userId);

    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
    });
    if (!project) throw new NotFoundException('Project not found');
    const updated = await this.prisma.message.updateMany({
      where: { jobId: project.jobId },
      data: { editedAt: new Date() },
    });
    return updated.count || 0;
  }

  async remove(id: string, userId: string): Promise<void> {
    const message = await this.findOne(id, userId);

    // Only allow sender to delete their own messages
    if (message.senderId !== userId) {
      throw new ForbiddenException('Only message sender can delete messages');
    }

    await this.prisma.message.delete({ where: { id } });
  }

  async getUnreadCount(projectId: string, userId: string): Promise<number> {
    await this.validateProjectAccess(projectId, userId);

    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
    });
    if (!project) throw new NotFoundException('Project not found');
    const count = await this.prisma.message.count({
      where: { jobId: project.jobId },
    });
    return count || 0;
  }

  async createSystemMessage(
    projectId: string,
    systemType: string,
    extraContent?: string,
  ): Promise<PrismaMessage> {
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
      include: { job: true },
    });

    if (!project) {
      throw new NotFoundException('Project not found');
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

  async searchMessages(
    projectId: string,
    userId: string,
    query: string,
    options?: { skip?: number; take?: number },
  ): Promise<PrismaMessage[]> {
    await this.validateProjectAccess(projectId, userId);
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
    });
    if (!project) throw new NotFoundException('Project not found');
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

  async validateProjectAccess(
    projectId: string,
    userId: string,
  ): Promise<void> {
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
    });

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    const isClient = project.clientId === userId;
    const isCraftsman = project.craftsmanId === userId;

    if (!isClient && !isCraftsman) {
      throw new ForbiddenException(
        'You do not have access to this project chat',
      );
    }
  }

  // Method to get conversation history with pagination
  async getConversationHistory(
    projectId: string,
    userId: string,
    options?: {
      before?: Date;
      after?: Date;
      limit?: number;
    },
  ): Promise<{ messages: PrismaMessage[]; total: number; hasMore: boolean }> {
    await this.validateProjectAccess(projectId, userId);
    const { before, after, limit = 50 } = options || {};
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
    });
    if (!project) throw new NotFoundException('Project not found');

    const where: any = { jobId: project.jobId };
    if (before) where.createdAt = { lt: before };
    if (after) where.createdAt = { gt: after };

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
}
