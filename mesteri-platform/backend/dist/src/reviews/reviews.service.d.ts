import { PrismaService } from '../prisma/prisma.service';
import type { Review as PrismaReview } from '@prisma/client';
import { ReviewType } from './review.entity';
export interface ReviewStats {
    averageRating: number;
    totalReviews: number;
    ratingDistribution: {
        [key: number]: number;
    };
    totalHelpfulVotes: number;
    responseRate: number;
    responseTimeAverage: number;
    responseTimeMedian: number;
    responseTimeMax: number;
    responseTimeMin: number;
    totalResponded?: number;
    averageResponseTime?: number;
}
export type { Review } from '@prisma/client';
export declare class ReviewsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    private readonly reviews;
    findAllReviews(): Promise<PrismaReview[]>;
    findReviewById(id: string): Promise<PrismaReview | null>;
    findReviewsByUserId(userId: string): Promise<PrismaReview[]>;
    createReview(reviewData: {
        rating: number;
        comment: string;
        type: ReviewType;
        projectId: string;
        revieweeId: string;
        reviewerId: string;
        qualityRating?: number;
        communicationRating?: number;
        punctualityRating?: number;
    }): Promise<PrismaReview>;
    updateReview(id: string, updateData: Partial<PrismaReview>): Promise<PrismaReview | null>;
    deleteReview(id: string): Promise<boolean>;
    getTopRatedUsers(minReviews?: number, minRating?: number): Promise<{
        userId: string;
        averageRating: number;
        totalReviews: number;
    }[]>;
    getRecentReviews(limit?: number): Promise<PrismaReview[]>;
    searchReviews(query: string): Promise<PrismaReview[]>;
    getTrendingReviews(days?: number): Promise<PrismaReview[]>;
    findReviewsByReviewerId(userId: string): Promise<PrismaReview[]>;
    findReviewsByProjectId(projectId: string): Promise<PrismaReview[]>;
    findReviewsByRating(rating: number): Promise<PrismaReview[]>;
    findReviewsByTag(tag: string): Promise<PrismaReview[]>;
    getReviewStats(userId?: string): Promise<ReviewStats>;
    getReviewHistory(userId: string, limit?: number): Promise<PrismaReview[]>;
    approveReview(id: string): Promise<boolean>;
    rejectReview(id: string, reason: string): Promise<boolean>;
    reportReview(id: string, reason: string): Promise<boolean>;
    markAsHelpful(id: string, isHelpful: boolean): Promise<boolean>;
    respondToReview(id: string, response: string): Promise<boolean>;
    flagReviewAsInappropriate(id: string, reason: string): Promise<boolean>;
    removeInappropriateFlag(id: string): Promise<boolean>;
    getFlaggedReviews(): Promise<PrismaReview[]>;
    getReviewWithResponses(id: string): Promise<PrismaReview | null>;
    getReviewsWithResponses(userId?: string): any[];
    getReviewResponseStats(userId?: string): Promise<ReviewStats>;
}
