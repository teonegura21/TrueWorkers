import { IsString, IsBoolean, IsOptional, IsUUID } from 'class-validator';

export class UpdateNotificationDto {
  @IsString()
  @IsOptional()
  title?: string;

  @IsString()
  @IsOptional()
  message?: string;

  @IsString()
  @IsOptional()
  type?: string;

  @IsBoolean()
  @IsOptional()
  isRead?: boolean;

  @IsUUID()
  @IsOptional()
  jobId?: string;
}
