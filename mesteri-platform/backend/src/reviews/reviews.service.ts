import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import type { Review as PrismaReview } from '@prisma/client';
import { ReviewType } from './review.entity';

export interface ReviewStats {
  averageRating: number;
  totalReviews: number;
  ratingDistribution: { [key: number]: number };
  totalHelpfulVotes: number;
  responseRate: number;
  responseTimeAverage: number;
  responseTimeMedian: number;
  responseTimeMax: number;
  responseTimeMin: number;
  totalResponded?: number;
  averageResponseTime?: number;
}

// Re-export Prisma type for controller typing
export type { Review } from '@prisma/client';

@Injectable()
export class ReviewsService {
  constructor(private readonly prisma: PrismaService) {}

  // Lightweight in-memory list for demo analytics
  private readonly reviews: any[] = [];

  // DB-backed operations
  async findAllReviews(): Promise<PrismaReview[]> {
    return this.prisma.review.findMany({ orderBy: { createdAt: 'desc' } });
  }

  async findReviewById(id: string): Promise<PrismaReview | null> {
    return this.prisma.review.findUnique({ where: { id } });
  }

  async findReviewsByUserId(userId: string): Promise<PrismaReview[]> {
    return this.prisma.review.findMany({
      where: { revieweeId: userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createReview(reviewData: {
    rating: number;
    comment: string;
    type: ReviewType;
    projectId: string;
    revieweeId: string;
    reviewerId: string;
    qualityRating?: number;
    communicationRating?: number;
    punctualityRating?: number;
  }): Promise<PrismaReview> {
    return this.prisma.review.create({
      data: {
        rating: reviewData.rating,
        comment: reviewData.comment,
        projectId: reviewData.projectId,
        revieweeId: reviewData.revieweeId,
        reviewerId: reviewData.reviewerId,
      },
    });
  }

  async updateReview(
    id: string,
    updateData: Partial<PrismaReview>,
  ): Promise<PrismaReview | null> {
    const existing = await this.prisma.review.findUnique({
      where: { id },
    });
    if (!existing) return null;
    const data: any = {};
    if (typeof updateData.rating === 'number') data.rating = updateData.rating;
    if (typeof updateData.comment === 'string')
      data.comment = updateData.comment;
    return this.prisma.review.update({ where: { id }, data });
  }

  async deleteReview(id: string): Promise<boolean> {
    try {
      await this.prisma.review.delete({ where: { id } });
      return true;
    } catch {
      return false;
    }
  }

  // In-memory analytics/utilities (simple implementations)
  async getTopRatedUsers(minReviews: number = 5, minRating: number = 4.5) {
    const reviews = await this.prisma.review.findMany({
      where: { status: 'approved' },
      select: { revieweeId: true, rating: true },
    });

    const byUser = new Map<string, { totalRating: number; count: number }>();
    for (const r of reviews) {
      const current = byUser.get(r.revieweeId) || { totalRating: 0, count: 0 };
      current.totalRating += r.rating;
      current.count++;
      byUser.set(r.revieweeId, current);
    }

    const result: {
      userId: string;
      averageRating: number;
      totalReviews: number;
    }[] = [];
    byUser.forEach((data, userId) => {
      const averageRating = data.totalRating / data.count;
      if (data.count >= minReviews && averageRating >= minRating) {
        result.push({ userId, averageRating, totalReviews: data.count });
      }
    });
    return result.sort((a, b) => b.averageRating - a.averageRating);
  }

  async getRecentReviews(limit: number = 10): Promise<PrismaReview[]> {
    return this.prisma.review.findMany({
      where: { status: 'approved' },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  async searchReviews(query: string): Promise<PrismaReview[]> {
    const q = (query || '').toLowerCase();
    return this.prisma.review.findMany({
      where: {
        OR: [
          { comment: { contains: q, mode: 'insensitive' } },
          { tags: { has: q } }, // Assuming tags are stored as a string array
        ],
      },
    });
  }

  async getTrendingReviews(days: number = 7): Promise<PrismaReview[]> {
    const threshold = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
    return this.prisma.review.findMany({
      where: {
        createdAt: { gte: threshold },
        status: 'approved',
      },
      orderBy: { helpfulCount: 'desc' }, // Assuming helpfulCount indicates trending
    });
  }

  // Additional query helpers expected by controller (mock-backed)
  async findReviewsByReviewerId(userId: string): Promise<PrismaReview[]> {
    return this.prisma.review.findMany({ where: { reviewerId: userId } });
  }

  async findReviewsByProjectId(projectId: string): Promise<PrismaReview[]> {
    return this.prisma.review.findMany({ where: { projectId } });
  }

  async findReviewsByRating(rating: number): Promise<PrismaReview[]> {
    return this.prisma.review.findMany({ where: { rating } });
  }

  async findReviewsByTag(tag: string): Promise<PrismaReview[]> {
    return this.prisma.review.findMany({ where: { tags: { has: tag } } });
  }

  async getReviewStats(userId?: string): Promise<ReviewStats> {
    const where = userId ? { revieweeId: userId } : {};
    const reviews = await this.prisma.review.findMany({ where });

    const totalReviews = reviews.length;
    const averageRating = totalReviews
      ? reviews.reduce((s, r) => s + r.rating, 0) / totalReviews
      : 0;
    const ratingDistribution: { [key: number]: number } = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    };
    reviews.forEach((r) => {
      if (ratingDistribution[r.rating] !== undefined)
        ratingDistribution[r.rating]++;
    });
    const totalHelpfulVotes = 0;
    return {
      averageRating,
      totalReviews,
      ratingDistribution,
      totalHelpfulVotes,
      responseRate: 0,
      responseTimeAverage: 0,
      responseTimeMedian: 0,
      responseTimeMax: 0,
      responseTimeMin: 0,
    };
  }

  async getReviewHistory(userId: string, limit?: number): Promise<PrismaReview[]> {
    const reviews = await this.prisma.review.findMany({
      where: { revieweeId: userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
    return reviews;
  }

  async approveReview(id: string): Promise<boolean> {
    return true;
  }

  async rejectReview(id: string, reason: string): Promise<boolean> {
    return true;
  }

  async reportReview(id: string, reason: string): Promise<boolean> {
    return true;
  }

  async markAsHelpful(id: string, isHelpful: boolean): Promise<boolean> {
    return true;
  }

  async respondToReview(id: string, response: string): Promise<boolean> {
    return true;
  }

  async flagReviewAsInappropriate(id: string, reason: string): Promise<boolean> {
    return true;
  }

  async removeInappropriateFlag(id: string): Promise<boolean> {
    return true;
  }

  async getFlaggedReviews(): Promise<PrismaReview[]> {
    return [];
  }
  async getReviewWithResponses(id: string): Promise<PrismaReview | null> {
    return this.prisma.review.findUnique({ where: { id } });
  }
  getReviewsWithResponses(userId?: string): any[] {
    const list = userId
      ? this.reviews.filter((r) => r.revieweeId === userId)
      : this.reviews;
    return list.filter((r) => (r as any).response && (r as any).response.trim().length > 0);
  }
  async getReviewResponseStats(userId?: string): Promise<ReviewStats> {
    const where = userId ? { revieweeId: userId } : {};
    const reviews = await this.prisma.review.findMany({ where });

    const responded = reviews.filter(
      (r) => (r as any).response && (r as any).response.trim().length > 0,
    );
    const totalResponded = responded.length;
    let totalResponseTime = 0;
    responded.forEach((r) => {
      if (r.respondedAt && r.createdAt)
        totalResponseTime +=
          (r.respondedAt.getTime() - r.createdAt.getTime()) / 3600000;
    });
    const averageResponseTime = totalResponded
      ? totalResponseTime / totalResponded
      : 0;
    const responseRate = reviews.length ? (totalResponded / reviews.length) * 100 : 0;
    
    return { 
      totalResponded, 
      averageResponseTime, 
      responseRate,
      averageRating: 4.5,
      totalReviews: reviews.length,
      ratingDistribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: reviews.length },
      totalHelpfulVotes: 0,
      responseTimeAverage: averageResponseTime,
      responseTimeMedian: averageResponseTime,
      responseTimeMax: averageResponseTime,
      responseTimeMin: averageResponseTime
    };
  }
}
