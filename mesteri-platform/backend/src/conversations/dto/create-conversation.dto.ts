import { IsArray, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateConversationDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsUUID()
  projectId?: string;

  @IsArray()
  @IsUUID(undefined, { each: true })
  participantIds: string[];
}
