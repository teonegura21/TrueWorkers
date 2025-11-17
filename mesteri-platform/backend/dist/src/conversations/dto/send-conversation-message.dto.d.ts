import { MessageKind } from '@prisma/client';
export declare class SendConversationMessageDto {
    conversationId: string;
    kind?: MessageKind;
    body?: string;
    attachmentIds?: string[];
}
