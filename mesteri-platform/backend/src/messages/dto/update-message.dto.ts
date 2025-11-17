import { IsBoolean, IsOptional } from 'class-validator';

export class UpdateMessageDto {
  @IsBoolean()
  @IsOptional()
  isRead?: boolean;
}

export class MarkAsReadDto {
  @IsBoolean()
  @IsOptional()
  markAsRead?: boolean;
}
