import { JobCategory } from "@prisma/client";
export interface CraftsmanInsightDto {
    id: string;
    name: string;
    rating: number | null;
    completedProjects: number;
    responseTimeHours: number | null;
    trustBadges: string[];
}
export interface ServiceInsightDto {
    categoryId: string;
    categoryName: string;
    summary: string | null;
    averageBudget: number | null;
    averageBid: number | null;
    averageDurationDays: number | null;
    satisfactionScore: number | null;
    topCraftsmen: CraftsmanInsightDto[];
    gallery: string[];
    topSkills: string[];
    metadata: {
        categoryCode: JobCategory;
        totalJobs: number;
        totalOffers: number;
        totalProjects: number;
    };
}
export interface ServicesOverviewResponse {
    data: ServiceInsightDto[];
    fetchedAt: string;
}
