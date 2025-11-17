import { IsString, IsBoolean, IsOptional, IsUUID } from 'class-validator';

export class CreateNotificationDto {
  @IsString()
  title: string;

  @IsString()
  message: string;

  @IsString()
  type: string;

  @IsBoolean()
  @IsOptional()
  isRead?: boolean = false;

  @IsUUID()
  userId: string;

  @IsUUID()
  @IsOptional()
  jobId?: string;
}
