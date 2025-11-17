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
exports.AnalyticsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let AnalyticsService = class AnalyticsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async trackEvent(data) {
        return this.prisma.analyticsEvent.create({
            data: {
                userId: data.userId,
                sessionId: data.sessionId,
                eventType: data.eventType,
                eventName: data.eventName,
                properties: data.properties || {},
                platform: data.platform,
                appVersion: data.appVersion,
                deviceInfo: data.deviceInfo,
                ipAddress: data.ipAddress,
                userAgent: data.userAgent,
                referrer: data.referrer,
                latitude: data.latitude,
                longitude: data.longitude,
                city: data.city,
                country: data.country,
            },
        });
    }
    async getUserEvents(userId, limit = 100) {
        return this.prisma.analyticsEvent.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            take: limit,
        });
    }
    async getEventsByType(eventType, limit = 100) {
        return this.prisma.analyticsEvent.findMany({
            where: { eventType },
            orderBy: { createdAt: 'desc' },
            take: limit,
        });
    }
    async getEventsInRange(startDate, endDate) {
        return this.prisma.analyticsEvent.findMany({
            where: {
                createdAt: {
                    gte: startDate,
                    lte: endDate,
                },
            },
            orderBy: { createdAt: 'desc' },
        });
    }
    async getEventStats(userId) {
        const where = userId ? { userId } : {};
        const [totalEvents, eventsByType, uniqueUsers, uniqueSessions] = await Promise.all([
            this.prisma.analyticsEvent.count({ where }),
            this.prisma.analyticsEvent.groupBy({
                by: ['eventType'],
                where,
                _count: true,
            }),
            this.prisma.analyticsEvent.findMany({
                where,
                distinct: ['userId'],
                select: { userId: true },
            }),
            this.prisma.analyticsEvent.findMany({
                where,
                distinct: ['sessionId'],
                select: { sessionId: true },
            }),
        ]);
        return {
            totalEvents,
            eventsByType: eventsByType.map((e) => ({
                type: e.eventType,
                count: e._count,
            })),
            uniqueUsers: uniqueUsers.filter((u) => u.userId).length,
            uniqueSessions: uniqueSessions.filter((s) => s.sessionId).length,
        };
    }
    async recordSearch(data) {
        return this.prisma.searchHistory.create({
            data: {
                userId: data.userId,
                query: data.query,
                filters: data.filters,
                category: data.category,
                location: data.location,
                latitude: data.latitude,
                longitude: data.longitude,
                radiusKm: data.radiusKm,
                resultsCount: data.resultsCount,
                clickedResults: data.clickedResults || [],
            },
        });
    }
    async getUserSearchHistory(userId, limit = 50) {
        return this.prisma.searchHistory.findMany({
            where: { userId },
            orderBy: { searchedAt: 'desc' },
            take: limit,
        });
    }
    async getPopularSearches(limit = 10) {
        const searches = await this.prisma.searchHistory.groupBy({
            by: ['query'],
            _count: true,
            orderBy: {
                _count: {
                    query: 'desc',
                },
            },
            take: limit,
        });
        return searches.map((s) => ({
            query: s.query,
            count: s._count,
        }));
    }
    async getSearchSuggestions(userId, partialQuery, limit = 5) {
        const recentSearches = await this.prisma.searchHistory.findMany({
            where: {
                userId,
                query: {
                    contains: partialQuery,
                    mode: 'insensitive',
                },
            },
            orderBy: { searchedAt: 'desc' },
            take: limit,
            distinct: ['query'],
        });
        return recentSearches.map((s) => s.query);
    }
    async clearSearchHistory(userId) {
        return this.prisma.searchHistory.deleteMany({
            where: { userId },
        });
    }
    async recordSearchClick(searchId, resultId) {
        const search = await this.prisma.searchHistory.findUnique({
            where: { id: searchId },
        });
        if (!search)
            return null;
        const clickedResults = search.clickedResults || [];
        if (!clickedResults.includes(resultId)) {
            clickedResults.push(resultId);
        }
        return this.prisma.searchHistory.update({
            where: { id: searchId },
            data: { clickedResults },
        });
    }
    async saveCraftsman(data) {
        return this.prisma.savedCraftsman.create({
            data: {
                userId: data.userId,
                craftsmanId: data.craftsmanId,
                notes: data.notes,
                tags: data.tags || [],
            },
        });
    }
    async unsaveCraftsman(userId, craftsmanId) {
        return this.prisma.savedCraftsman.delete({
            where: {
                userId_craftsmanId: {
                    userId,
                    craftsmanId,
                },
            },
        });
    }
    async getSavedCraftsmen(userId) {
        return this.prisma.savedCraftsman.findMany({
            where: { userId },
            include: {
                craftsman: {
                    select: {
                        id: true,
                        fullName: true,
                        email: true,
                        profileImage: true,
                        profilePicture: true,
                        city: true,
                        county: true,
                        specialties: true,
                        averageRating: true,
                        totalReviews: true,
                        isVerified: true,
                        yearsExperience: true,
                        portfolioPhotos: true,
                    },
                },
            },
            orderBy: { savedAt: 'desc' },
        });
    }
    async isCraftsmanSaved(userId, craftsmanId) {
        const saved = await this.prisma.savedCraftsman.findUnique({
            where: {
                userId_craftsmanId: {
                    userId,
                    craftsmanId,
                },
            },
        });
        return !!saved;
    }
    async updateSavedCraftsman(userId, craftsmanId, data) {
        return this.prisma.savedCraftsman.update({
            where: {
                userId_craftsmanId: {
                    userId,
                    craftsmanId,
                },
            },
            data,
        });
    }
    async getCraftsmenSaveStats(craftsmanId) {
        const count = await this.prisma.savedCraftsman.count({
            where: { craftsmanId },
        });
        return { craftsmanId, saveCount: count };
    }
    async getUserEngagement(userId) {
        const [totalEvents, searchCount, savedCraftsmenCount, recentActivity,] = await Promise.all([
            this.prisma.analyticsEvent.count({ where: { userId } }),
            this.prisma.searchHistory.count({ where: { userId } }),
            this.prisma.savedCraftsman.count({ where: { userId } }),
            this.prisma.analyticsEvent.findMany({
                where: { userId },
                orderBy: { createdAt: 'desc' },
                take: 10,
            }),
        ]);
        return {
            totalEvents,
            searchCount,
            savedCraftsmenCount,
            recentActivity,
        };
    }
    async getPlatformAnalytics() {
        const now = new Date();
        const last30Days = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        const [totalUsers, totalEvents, totalSearches, activeUsers, popularSearches,] = await Promise.all([
            this.prisma.user.count(),
            this.prisma.analyticsEvent.count(),
            this.prisma.searchHistory.count(),
            this.prisma.analyticsEvent.findMany({
                where: {
                    createdAt: { gte: last30Days },
                },
                distinct: ['userId'],
                select: { userId: true },
            }),
            this.getPopularSearches(10),
        ]);
        return {
            totalUsers,
            totalEvents,
            totalSearches,
            activeUsersLast30Days: activeUsers.filter((u) => u.userId).length,
            popularSearches,
        };
    }
};
exports.AnalyticsService = AnalyticsService;
exports.AnalyticsService = AnalyticsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AnalyticsService);
//# sourceMappingURL=analytics.service.js.map