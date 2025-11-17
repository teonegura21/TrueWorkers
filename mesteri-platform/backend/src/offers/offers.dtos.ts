import {
  IsString,
  IsOptional,
  IsUUID,
  IsNumber,
  IsArray,
  Min,
  IsPositive,
} from 'class-validator';

export class CreateOfferDto {
  @IsUUID()
  jobId: string;

  @IsNumber()
  @Min(0.01)
  bidAmount: number;

  @IsString()
  description: string;

  @IsPositive()
  @IsNumber()
  estimatedDays: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  attachments?: string[];

  // For backward compatibility - will be mapped to bidAmount
  @IsOptional()
  @IsNumber()
  @Min(0.01)
  proposedPrice?: number;
}

export class UpdateOfferDto {
  @IsOptional()
  @IsNumber()
  @Min(0.01)
  proposedPrice?: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsNumber()
  estimatedDays?: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  attachments?: string[];
}
