import { ContractStatus } from '@prisma/client';

export class ContractResponseDto {
  id: string;
  projectId: string;
  status: ContractStatus;
  version: number;
  signRequestViewUrl?: string;
  signedDocumentUrl?: string;
  createdAt: Date;
}
