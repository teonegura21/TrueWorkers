import { IsEnum, IsOptional, IsString } from 'class-validator';

export enum MediaCategory {
  PORTFOLIO = 'PORTFOLIO',
  PROFILE = 'PROFILE',
  JOB = 'JOB',
  BEFORE_AFTER = 'BEFORE_AFTER',
  INSPIRATION = 'INSPIRATION',
}

export class UploadMediaDto {
  @IsEnum(MediaCategory)
  category: MediaCategory;

  @IsOptional()
  @IsString()
  entityId?: string;
}
