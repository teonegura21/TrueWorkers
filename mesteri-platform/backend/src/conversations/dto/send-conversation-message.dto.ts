import {
  IsArray,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
} from 'class-validator';
import { MessageKind } from '@prisma/client';

export class SendConversationMessageDto {
  @IsUUID()
  conversationId: string;

  @IsOptional()
  @IsEnum(MessageKind)
  kind?: MessageKind = MessageKind.TEXT;

  @IsOptional()
  @IsString()
  @MaxLength(4000)
  body?: string;

  @IsOptional()
  @IsArray()
  @IsUUID(undefined, { each: true })
  attachmentIds?: string[];
}
