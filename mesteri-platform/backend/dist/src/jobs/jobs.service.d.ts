import { PrismaService } from '../prisma/prisma.service';
import { Job, JobStatus, JobCategory, Prisma } from '@prisma/client';
import { ServicesOverviewResponse } from './dto/service-insight.dto';
export type { Job };
export declare class JobsService {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(): Promise<Job[]>;
    findOne(id: string): Promise<Job>;
    findByClientId(clientId: string): Promise<Job[]>;
    findByStatus(status: JobStatus): Promise<Job[]>;
    create(jobData: {
        title: string;
        description: string;
        category: JobCategory;
        location: string;
        budgetMin: number;
        budgetMax: number;
        clientId: string;
    }): Promise<Job>;
    update(id: string, updateData: Prisma.JobUpdateInput): Promise<Job>;
    delete(id: string): Promise<void>;
    searchAndFilter(query?: string, filters?: {
        category?: JobCategory;
        status?: JobStatus;
        minBudget?: number;
        maxBudget?: number;
        location?: string;
        clientId?: string;
        page?: number;
        limit?: number;
    }): Promise<{
        jobs: Job[];
        total: number;
    }>;
    advancedSearch(searchDto: {
        q?: string;
        category?: JobCategory;
        status?: JobStatus;
        minBudget?: number;
        maxBudget?: number;
        city?: string;
        latitude?: number;
        longitude?: number;
        radius?: number;
        urgency?: any;
        sortBy?: string;
        page?: number;
        limit?: number;
    }): Promise<{
        data: any[];
        meta: any;
    }>;
    private searchWithGeolocation;
    getJobsByCategory(category: JobCategory, filters?: {
        status?: JobStatus;
        location?: string;
        page?: number;
        limit?: number;
    }): Promise<{
        jobs: Job[];
        total: number;
    }>;
    getActiveJobs(filters?: {
        category?: JobCategory;
        location?: string;
        page?: number;
        limit?: number;
    }): Promise<{
        jobs: Job[];
        total: number;
    }>;
    getMarketingFeed(limit?: number): Promise<{
        id: string;
        title: string;
        description: string;
        location: string;
        city: string;
        category: import("@prisma/client").$Enums.JobCategory;
        budgetMin: number;
        budgetMax: number;
        mediaUrls: string[];
        clientName: string;
        createdAt: Date;
    }[]>;
    getAvailableJobsForCraftsman(craftsmanId: string, specialty?: JobCategory, filters?: {
        location?: string;
        minBudget?: number;
        maxBudget?: number;
        page?: number;
        limit?: number;
    }): Promise<{
        jobs: Job[];
        total: number;
    }>;
    private resolveCategory;
    private normalizeOverviewLimit;
    private getCategoryPresentation;
    private average;
    private buildTrustBadges;
    private buildCategoryInsight;
    getServicesOverview(params?: {
        categoryId?: string;
        limit?: number;
    }): Promise<ServicesOverviewResponse>;
    findByCategory(category: string): Promise<Job[]>;
    search(query: string): Promise<{
        jobs: Job[];
        total: number;
    }>;
}
