import {
  IsString,
  IsNumber,
  IsDateString,
  IsOptional,
  MinLength,
  MaxLength,
  IsPositive,
  Min,
} from 'class-validator';

export class UpdateMilestoneDto {
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(200)
  title?: string;

  @IsOptional()
  @IsString()
  @MinLength(10)
  @MaxLength(1000)
  description?: string;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  estimatedCost?: number;

  @IsOptional()
  @IsDateString()
  estimatedEndDate?: string;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @IsPositive()
  order?: number;
}
