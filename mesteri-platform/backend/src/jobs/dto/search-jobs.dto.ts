import { IsOptional, IsEnum, IsNumber, IsString, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';
import { JobCategory, JobStatus, UrgencyLevel } from '@prisma/client';

export enum SortBy {
  NEWEST = 'newest',
  CLOSEST = 'closest',
  BUDGET_HIGH = 'budget_high',
  BUDGET_LOW = 'budget_low',
  DEADLINE = 'deadline',
}

/**
 * DTO for Job Search Query Parameters
 */
export class SearchJobsQueryDto {
  @IsOptional()
  @IsString()
  q?: string;

  @IsOptional()
  @IsEnum(JobCategory)
  category?: JobCategory;

  @IsOptional()
  @IsEnum(JobStatus)
  status?: JobStatus = JobStatus.ACTIVE;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  minBudget?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  maxBudget?: number;

  @IsOptional()
  @IsString()
  city?: string;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  latitude?: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  longitude?: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  @Type(() => Number)
  radius?: number = 50;

  @IsOptional()
  @IsEnum(UrgencyLevel)
  urgency?: UrgencyLevel;

  @IsOptional()
  @IsEnum(SortBy)
  sortBy?: SortBy = SortBy.NEWEST;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  page?: number = 1;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(50)
  @Type(() => Number)
  limit?: number = 20;
}

/**
 * DTO for Job Search Response with Pagination
 */
export class SearchJobsResponseDto {
  data: any[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
