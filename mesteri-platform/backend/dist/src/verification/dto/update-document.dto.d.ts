import { DocumentStatus } from '@prisma/client';
export declare class UpdateDocumentDto {
    status?: DocumentStatus;
    rejectionReason?: string;
}
