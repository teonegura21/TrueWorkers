import { MessageKind } from '@prisma/client';
export declare class CreateMessageDto {
    content: string;
    messageType?: MessageKind;
    projectId: string;
    receiverId: string;
    attachments?: any[];
    metadata?: {
        fileName?: string;
        fileSize?: number;
        mimeType?: string;
        originalName?: string;
        location?: string;
        thumbnail?: string;
    };
}
