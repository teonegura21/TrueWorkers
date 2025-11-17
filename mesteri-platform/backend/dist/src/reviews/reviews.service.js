"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReviewsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let ReviewsService = class ReviewsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    reviews = [];
    async findAllReviews() {
        return this.prisma.review.findMany({ orderBy: { createdAt: 'desc' } });
    }
    async findReviewById(id) {
        return this.prisma.review.findUnique({ where: { id } });
    }
    async findReviewsByUserId(userId) {
        return this.prisma.review.findMany({
            where: { revieweeId: userId },
            orderBy: { createdAt: 'desc' },
        });
    }
    async createReview(reviewData) {
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
    async updateReview(id, updateData) {
        const existing = await this.prisma.review.findUnique({
            where: { id },
        });
        if (!existing)
            return null;
        const data = {};
        if (typeof updateData.rating === 'number')
            data.rating = updateData.rating;
        if (typeof updateData.comment === 'string')
            data.comment = updateData.comment;
        return this.prisma.review.update({ where: { id }, data });
    }
    async deleteReview(id) {
        try {
            await this.prisma.review.delete({ where: { id } });
            return true;
        }
        catch {
            return false;
        }
    }
    async getTopRatedUsers(minReviews = 5, minRating = 4.5) {
        const reviews = await this.prisma.review.findMany({
            where: { status: 'approved' },
            select: { revieweeId: true, rating: true },
        });
        const byUser = new Map();
        for (const r of reviews) {
            const current = byUser.get(r.revieweeId) || { totalRating: 0, count: 0 };
            current.totalRating += r.rating;
            current.count++;
            byUser.set(r.revieweeId, current);
        }
        const result = [];
        byUser.forEach((data, userId) => {
            const averageRating = data.totalRating / data.count;
            if (data.count >= minReviews && averageRating >= minRating) {
                result.push({ userId, averageRating, totalReviews: data.count });
            }
        });
        return result.sort((a, b) => b.averageRating - a.averageRating);
    }
    async getRecentReviews(limit = 10) {
        return this.prisma.review.findMany({
            where: { status: 'approved' },
            orderBy: { createdAt: 'desc' },
            take: limit,
        });
    }
    async searchReviews(query) {
        const q = (query || '').toLowerCase();
        return this.prisma.review.findMany({
            where: {
                OR: [
                    { comment: { contains: q, mode: 'insensitive' } },
                    { tags: { has: q } },
                ],
            },
        });
    }
    async getTrendingReviews(days = 7) {
        const threshold = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
        return this.prisma.review.findMany({
            where: {
                createdAt: { gte: threshold },
                status: 'approved',
            },
            orderBy: { helpfulCount: 'desc' },
        });
    }
    async findReviewsByReviewerId(userId) {
        return this.prisma.review.findMany({ where: { reviewerId: userId } });
    }
    async findReviewsByProjectId(projectId) {
        return this.prisma.review.findMany({ where: { projectId } });
    }
    async findReviewsByRating(rating) {
        return this.prisma.review.findMany({ where: { rating } });
    }
    async findReviewsByTag(tag) {
        return this.prisma.review.findMany({ where: { tags: { has: tag } } });
    }
    async getReviewStats(userId) {
        const where = userId ? { revieweeId: userId } : {};
        const reviews = await this.prisma.review.findMany({ where });
        const totalReviews = reviews.length;
        const averageRating = totalReviews
            ? reviews.reduce((s, r) => s + r.rating, 0) / totalReviews
            : 0;
        const ratingDistribution = {
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
    async getReviewHistory(userId, limit) {
        const reviews = await this.prisma.review.findMany({
            where: { revieweeId: userId },
            orderBy: { createdAt: 'desc' },
            take: limit,
        });
        return reviews;
    }
    async approveReview(id) {
        return true;
    }
    async rejectReview(id, reason) {
        return true;
    }
    async reportReview(id, reason) {
        return true;
    }
    async markAsHelpful(id, isHelpful) {
        return true;
    }
    async respondToReview(id, response) {
        return true;
    }
    async flagReviewAsInappropriate(id, reason) {
        return true;
    }
    async removeInappropriateFlag(id) {
        return true;
    }
    async getFlaggedReviews() {
        return [];
    }
    async getReviewWithResponses(id) {
        return this.prisma.review.findUnique({ where: { id } });
    }
    getReviewsWithResponses(userId) {
        const list = userId
            ? this.reviews.filter((r) => r.revieweeId === userId)
            : this.reviews;
        return list.filter((r) => r.response && r.response.trim().length > 0);
    }
    async getReviewResponseStats(userId) {
        const where = userId ? { revieweeId: userId } : {};
        const reviews = await this.prisma.review.findMany({ where });
        const responded = reviews.filter((r) => r.response && r.response.trim().length > 0);
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
};
exports.ReviewsService = ReviewsService;
exports.ReviewsService = ReviewsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ReviewsService);
//# sourceMappingURL=reviews.service.js.map