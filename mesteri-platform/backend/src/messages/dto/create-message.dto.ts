import {
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  IsObject,
} from 'class-validator';
import { MessageKind } from '@prisma/client';

export class CreateMessageDto {
  @IsString()
  @MaxLength(2000)
  content: string;

  @IsEnum(MessageKind)
  @IsOptional()
  messageType?: MessageKind;

  @IsUUID()
  projectId: string;

  @IsUUID()
  receiverId: string;

  @IsOptional()
  @IsObject()
  attachments?: any[];

  @IsOptional()
  @IsObject()
  metadata?: {
    fileName?: string;
    fileSize?: number;
    mimeType?: string;
    originalName?: string;
    location?: string;
    thumbnail?: string;
  };
}
