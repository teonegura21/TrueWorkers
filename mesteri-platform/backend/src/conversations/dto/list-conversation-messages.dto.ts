import { IsInt, IsOptional, IsUUID, Min } from 'class-validator';

export class ListConversationMessagesDto {
  @IsUUID()
  conversationId: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  skip?: number = 0;

  @IsOptional()
  @IsInt()
  @Min(1)
  take?: number = 50;
}
