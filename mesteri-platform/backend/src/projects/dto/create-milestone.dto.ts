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

export class CreateMilestoneDto {
  @IsString()
  @MinLength(3)
  @MaxLength(200)
  title: string;

  @IsString()
  @MinLength(10)
  @MaxLength(1000)
  description: string;

  @IsNumber()
  @IsPositive()
  estimatedCost: number;

  @IsDateString()
  estimatedEndDate: string;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @IsPositive()
  order?: number;
}
