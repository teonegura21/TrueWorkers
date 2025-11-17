import { ConversationsService } from './conversations.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendConversationMessageDto } from './dto/send-conversation-message.dto';
import { ListConversationMessagesDto } from './dto/list-conversation-messages.dto';
interface RequestUser {
    user: {
        userId: string;
    };
}
export declare class ConversationsController {
    private readonly conversations;
    constructor(conversations: ConversationsService);
    list(req: RequestUser): Promise<{
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
    create(dto: CreateConversationDto, req: RequestUser): Promise<{
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
    ensureProjectConversation(projectId: string, req: RequestUser): Promise<{
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
    sendMessage(dto: SendConversationMessageDto, req: RequestUser): Promise<{
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
    listMessages(conversationId: string, query: ListConversationMessagesDto, req: RequestUser): Promise<{
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
    markRead(conversationId: string, messageId: string | undefined, req: RequestUser): Promise<{
        status: string;
    }>;
    getUnreadCount(conversationId: string, req: RequestUser): Promise<{
        count: number;
    }>;
}
export {};
