import { DocumentStatus } from '@prisma/client';

export class UpdateDocumentDto {
  status?: DocumentStatus;
  rejectionReason?: string;
}
