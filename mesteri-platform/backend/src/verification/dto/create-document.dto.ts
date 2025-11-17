import { DocumentType } from '@prisma/client';

export class CreateDocumentDto {
  type: DocumentType;
  url: string;
  fileName: string;
}
