import { JobCategory, JobStatus, UrgencyLevel } from '@prisma/client';
export declare enum SortBy {
    NEWEST = "newest",
    CLOSEST = "closest",
    BUDGET_HIGH = "budget_high",
    BUDGET_LOW = "budget_low",
    DEADLINE = "deadline"
}
export declare class SearchJobsQueryDto {
    q?: string;
    category?: JobCategory;
    status?: JobStatus;
    minBudget?: number;
    maxBudget?: number;
    city?: string;
    latitude?: number;
    longitude?: number;
    radius?: number;
    urgency?: UrgencyLevel;
    sortBy?: SortBy;
    page?: number;
    limit?: number;
}
export declare class SearchJobsResponseDto {
    data: any[];
    meta: {
        total: number;
        page: number;
        limit: number;
        totalPages: number;
    };
}
