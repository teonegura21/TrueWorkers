import { AttachmentEntity } from '@prisma/client';
export declare class RequestSignedUrlDto {
    fileName: string;
    contentType: string;
    entityType?: AttachmentEntity;
    entityId?: string;
    bucketHint?: string;
}
