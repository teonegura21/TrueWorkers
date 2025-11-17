import { IsString, IsOptional, IsDateString } from 'class-validator';

export class CreateProjectDto {
  @IsOptional()
  @IsDateString()
  deadline?: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
