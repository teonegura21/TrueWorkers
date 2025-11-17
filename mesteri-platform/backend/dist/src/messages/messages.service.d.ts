import { PrismaService } from '../prisma/prisma.service';
import { Message as PrismaMessage } from '@prisma/client';
import { CreateMessageDto } from './dto/create-message.dto';
import { UpdateMessageDto } from './dto/update-message.dto';
export declare class MessagesService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    create(createMessageDto: CreateMessageDto, senderId: string): Promise<PrismaMessage>;
    findAllByProject(projectId: string, userId: string, options?: {
        skip?: number;
        take?: number;
    }): Promise<PrismaMessage[]>;
    findOne(id: string, userId: string): Promise<PrismaMessage>;
    update(id: string, updateMessageDto: UpdateMessageDto, userId: string): Promise<PrismaMessage>;
    markAllAsRead(projectId: string, userId: string): Promise<number>;
    remove(id: string, userId: string): Promise<void>;
    getUnreadCount(projectId: string, userId: string): Promise<number>;
    createSystemMessage(projectId: string, systemType: string, extraContent?: string): Promise<PrismaMessage>;
    searchMessages(projectId: string, userId: string, query: string, options?: {
        skip?: number;
        take?: number;
    }): Promise<PrismaMessage[]>;
    validateProjectAccess(projectId: string, userId: string): Promise<void>;
    getConversationHistory(projectId: string, userId: string, options?: {
        before?: Date;
        after?: Date;
        limit?: number;
    }): Promise<{
        messages: PrismaMessage[];
        total: number;
        hasMore: boolean;
    }>;
}
