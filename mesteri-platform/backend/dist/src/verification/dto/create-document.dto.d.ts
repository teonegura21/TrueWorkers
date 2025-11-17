import { DocumentType } from '@prisma/client';
export declare class CreateDocumentDto {
    type: DocumentType;
    url: string;
    fileName: string;
}
