import {
  IsEnum,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
} from 'class-validator';
import { AttachmentEntity } from '@prisma/client';

export class RequestSignedUrlDto {
  @IsString()
  @Matches(/^[\w\-. ]+$/, {
    message:
      'fileName may only include letters, digits, dash, dot, underscore and spaces',
  })
  @MaxLength(120)
  fileName: string;

  @IsString()
  @MaxLength(120)
  contentType: string;

  @IsOptional()
  @IsEnum(AttachmentEntity)
  entityType?: AttachmentEntity;

  @IsOptional()
  @IsString()
  entityId?: string;

  @IsOptional()
  @IsString()
  bucketHint?: string;
}
