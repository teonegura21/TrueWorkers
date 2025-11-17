import { PrismaService } from '../prisma/prisma.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendConversationMessageDto } from './dto/send-conversation-message.dto';
import { ListConversationMessagesDto } from './dto/list-conversation-messages.dto';
export declare class ConversationsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    listForUser(userId: string): Promise<{
        id: string;
        title: string;
        type: import("@prisma/client").$Enums.ConversationType;
        project: {
            id: string;
            title: string;
            status: string;
        };
        participants: {
            id: string;
            role: import("@prisma/client").$Enums.ConversationParticipantRole;
            name: string;
            avatarUrl: string;
        }[];
        unreadCount: number;
        lastMessage: any;
        updatedAt: any;
        isActive: boolean;
    }[]>;
    createConversation(dto: CreateConversationDto, creatorId: string): Promise<{
        id: string;
        title: string;
        type: import("@prisma/client").$Enums.ConversationType;
        project: {
            id: string;
            title: string;
            status: string;
        };
        participants: {
            id: string;
            role: import("@prisma/client").$Enums.ConversationParticipantRole;
            name: string;
            avatarUrl: string;
        }[];
        unreadCount: number;
        lastMessage: any;
        updatedAt: any;
        isActive: boolean;
    }>;
    ensureProjectConversation(projectId: string, userId: string): Promise<{
        id: string;
        title: string;
        type: import("@prisma/client").$Enums.ConversationType;
        project: {
            id: string;
            title: string;
            status: string;
        };
        participants: {
            id: string;
            role: import("@prisma/client").$Enums.ConversationParticipantRole;
            name: string;
            avatarUrl: string;
        }[];
        unreadCount: number;
        lastMessage: any;
        updatedAt: any;
        isActive: boolean;
    }>;
    sendMessage(senderId: string, dto: SendConversationMessageDto): Promise<{
        id: string;
        kind: import("@prisma/client").$Enums.MessageKind;
        body: string;
        sentAt: Date;
        editedAt: Date;
        sender: {
            id: string;
            name: string;
            avatarUrl: string;
        };
        attachments: {
            id: string;
            bucket: string;
            objectPath: string;
            contentType: string;
            fileSize: number;
            status: import("@prisma/client").$Enums.AttachmentStatus;
        }[];
    }>;
    listMessages(userId: string, query: ListConversationMessagesDto): Promise<{
        conversation: {
            id: string;
            title: string;
            type: import("@prisma/client").$Enums.ConversationType;
            project: {
                id: string;
                title: string;
                status: string;
            };
            participants: {
                id: string;
                role: import("@prisma/client").$Enums.ConversationParticipantRole;
                name: string;
                avatarUrl: string;
            }[];
            unreadCount: number;
            lastMessage: any;
            updatedAt: any;
            isActive: boolean;
        };
        items: {
            id: string;
            kind: import("@prisma/client").$Enums.MessageKind;
            body: string;
            sentAt: Date;
            editedAt: Date;
            sender: {
                id: string;
                name: string;
                avatarUrl: string;
            };
            attachments: {
                id: string;
                bucket: string;
                objectPath: string;
                contentType: string;
                fileSize: number;
                status: import("@prisma/client").$Enums.AttachmentStatus;
            }[];
        }[];
        meta: {
            total: number;
            skip: number;
            take: number;
        };
    }>;
    markConversationRead(conversationId: string, userId: string, messageId?: string): Promise<void>;
    getUnreadCount(conversationId: string, userId: string): Promise<number>;
    private ensureParticipant;
    private ensureRetentionPolicy;
    private mapRole;
    private mapConversation;
    private mapMessage;
    private computeUnreadCount;
    private fetchMessageWithRelations;
}
