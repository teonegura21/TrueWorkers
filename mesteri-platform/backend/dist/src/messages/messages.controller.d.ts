import { MessagesService } from './messages.service';
import { CreateMessageDto } from './dto/create-message.dto';
import { UpdateMessageDto } from './dto/update-message.dto';
interface RequestWithUser extends Request {
    user: {
        userId: string;
        email: string;
        role: string;
    };
}
export declare class MessagesController {
    private readonly messagesService;
    constructor(messagesService: MessagesService);
    create(createMessageDto: CreateMessageDto, req: RequestWithUser): Promise<{
        id: string;
        createdAt: Date;
        jobId: string | null;
        retentionPolicyId: string;
        kind: import("@prisma/client").$Enums.MessageKind;
        body: string | null;
        metadata: import("@prisma/client/runtime/library").JsonValue | null;
        sentAt: Date;
        editedAt: Date | null;
        deletedAt: Date | null;
        conversationId: string;
        senderId: string | null;
        replyToMessageId: string | null;
    }>;
    findAllByProject(projectId: string, req: RequestWithUser, skip?: string, take?: string): Promise<{
        id: string;
        createdAt: Date;
        jobId: string | null;
        retentionPolicyId: string;
        kind: import("@prisma/client").$Enums.MessageKind;
        body: string | null;
        metadata: import("@prisma/client/runtime/library").JsonValue | null;
        sentAt: Date;
        editedAt: Date | null;
        deletedAt: Date | null;
        conversationId: string;
        senderId: string | null;
        replyToMessageId: string | null;
    }[]>;
    findOne(id: string, req: RequestWithUser): Promise<{
        id: string;
        createdAt: Date;
        jobId: string | null;
        retentionPolicyId: string;
        kind: import("@prisma/client").$Enums.MessageKind;
        body: string | null;
        metadata: import("@prisma/client/runtime/library").JsonValue | null;
        sentAt: Date;
        editedAt: Date | null;
        deletedAt: Date | null;
        conversationId: string;
        senderId: string | null;
        replyToMessageId: string | null;
    }>;
    update(id: string, updateMessageDto: UpdateMessageDto, req: RequestWithUser): Promise<{
        id: string;
        createdAt: Date;
        jobId: string | null;
        retentionPolicyId: string;
        kind: import("@prisma/client").$Enums.MessageKind;
        body: string | null;
        metadata: import("@prisma/client/runtime/library").JsonValue | null;
        sentAt: Date;
        editedAt: Date | null;
        deletedAt: Date | null;
        conversationId: string;
        senderId: string | null;
        replyToMessageId: string | null;
    }>;
    markAllAsRead(projectId: string, req: RequestWithUser): Promise<number>;
    remove(id: string, req: RequestWithUser): Promise<void>;
    getUnreadCount(projectId: string, req: RequestWithUser): Promise<number>;
    searchMessages(projectId: string, query: string, req: RequestWithUser, skip?: string, take?: string): Promise<{
        id: string;
        createdAt: Date;
        jobId: string | null;
        retentionPolicyId: string;
        kind: import("@prisma/client").$Enums.MessageKind;
        body: string | null;
        metadata: import("@prisma/client/runtime/library").JsonValue | null;
        sentAt: Date;
        editedAt: Date | null;
        deletedAt: Date | null;
        conversationId: string;
        senderId: string | null;
        replyToMessageId: string | null;
    }[]>;
    getConversationHistory(projectId: string, req: RequestWithUser, before?: string, after?: string, limit?: string): Promise<{
        messages: import("@prisma/client").Message[];
        total: number;
        hasMore: boolean;
    }>;
}
export {};
