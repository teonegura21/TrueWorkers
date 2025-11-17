import { IsOptional, IsEnum, IsNumber, IsString, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';
import { JobCategory, JobStatus, UrgencyLevel, Job, User, Offer } from '@prisma/client';

export enum SortBy {
  NEWEST = 'newest',
  CLOSEST = 'closest',
  BUDGET_HIGH = 'budget_high',
  BUDGET_LOW = 'budget_low',
  DEADLINE = 'deadline',
}

/**
 * Job with enriched relations for search results
 */
export interface JobWithRelations extends Job {
  client?: {
    id: string;
    fullName: string;
    profileImage: string | null;
    averageRating: number | null;
    totalReviews: number | null;
  };
  offers?: Array<{
    id: string;
    bidAmount: number;
    estimatedDays: number;
    notes: string | null;
    craftsmanId: string;
    createdAt: Date;
  }>;
  distance?: number; // For geolocation searches
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
 * Pagination metadata
 */
export interface SearchMetadata {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

/**
 * DTO for Job Search Response with Pagination
 */
export class SearchJobsResponseDto {
  data: JobWithRelations[];
  meta: SearchMetadata;
}
