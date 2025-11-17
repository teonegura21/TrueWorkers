import { AnalyticsService, type TrackEventDto, type SearchHistoryDto, type SavedCraftsmanDto, type AnalyticsEventType } from './analytics.service';
export declare class AnalyticsController {
    private readonly analyticsService;
    constructor(analyticsService: AnalyticsService);
    trackEvent(data: TrackEventDto): Promise<{
        id: string;
        createdAt: Date;
        city: string | null;
        latitude: number | null;
        longitude: number | null;
        eventType: import("@prisma/client").$Enums.AnalyticsEventType;
        userId: string | null;
        platform: string | null;
        sessionId: string | null;
        eventName: string;
        properties: import("@prisma/client/runtime/library").JsonValue | null;
        appVersion: string | null;
        deviceInfo: import("@prisma/client/runtime/library").JsonValue | null;
        ipAddress: string | null;
        userAgent: string | null;
        referrer: string | null;
        country: string | null;
    }>;
    getUserEvents(userId: string, limit?: string): Promise<{
        id: string;
        createdAt: Date;
        city: string | null;
        latitude: number | null;
        longitude: number | null;
        eventType: import("@prisma/client").$Enums.AnalyticsEventType;
        userId: string | null;
        platform: string | null;
        sessionId: string | null;
        eventName: string;
        properties: import("@prisma/client/runtime/library").JsonValue | null;
        appVersion: string | null;
        deviceInfo: import("@prisma/client/runtime/library").JsonValue | null;
        ipAddress: string | null;
        userAgent: string | null;
        referrer: string | null;
        country: string | null;
    }[]>;
    getEventsByType(type: AnalyticsEventType, limit?: string): Promise<{
        id: string;
        createdAt: Date;
        city: string | null;
        latitude: number | null;
        longitude: number | null;
        eventType: import("@prisma/client").$Enums.AnalyticsEventType;
        userId: string | null;
        platform: string | null;
        sessionId: string | null;
        eventName: string;
        properties: import("@prisma/client/runtime/library").JsonValue | null;
        appVersion: string | null;
        deviceInfo: import("@prisma/client/runtime/library").JsonValue | null;
        ipAddress: string | null;
        userAgent: string | null;
        referrer: string | null;
        country: string | null;
    }[]>;
    getEventsInRange(start: string, end: string): Promise<{
        id: string;
        createdAt: Date;
        city: string | null;
        latitude: number | null;
        longitude: number | null;
        eventType: import("@prisma/client").$Enums.AnalyticsEventType;
        userId: string | null;
        platform: string | null;
        sessionId: string | null;
        eventName: string;
        properties: import("@prisma/client/runtime/library").JsonValue | null;
        appVersion: string | null;
        deviceInfo: import("@prisma/client/runtime/library").JsonValue | null;
        ipAddress: string | null;
        userAgent: string | null;
        referrer: string | null;
        country: string | null;
    }[]>;
    getEventStats(userId?: string): Promise<{
        totalEvents: number;
        eventsByType: {
            type: import("@prisma/client").$Enums.AnalyticsEventType;
            count: number;
        }[];
        uniqueUsers: number;
        uniqueSessions: number;
    }>;
    recordSearch(data: SearchHistoryDto): Promise<{
        query: string;
        id: string;
        latitude: number | null;
        longitude: number | null;
        category: string | null;
        location: string | null;
        radiusKm: number | null;
        userId: string;
        filters: import("@prisma/client/runtime/library").JsonValue | null;
        resultsCount: number | null;
        clickedResults: import("@prisma/client/runtime/library").JsonValue | null;
        searchedAt: Date;
    }>;
    getUserSearchHistory(userId: string, limit?: string): Promise<{
        query: string;
        id: string;
        latitude: number | null;
        longitude: number | null;
        category: string | null;
        location: string | null;
        radiusKm: number | null;
        userId: string;
        filters: import("@prisma/client/runtime/library").JsonValue | null;
        resultsCount: number | null;
        clickedResults: import("@prisma/client/runtime/library").JsonValue | null;
        searchedAt: Date;
    }[]>;
    getPopularSearches(limit?: string): Promise<{
        query: string;
        count: number;
    }[]>;
    getSearchSuggestions(userId: string, query: string, limit?: string): Promise<string[]>;
    clearSearchHistory(userId: string): Promise<import("@prisma/client").Prisma.BatchPayload>;
    recordSearchClick(searchId: string, resultId: string): Promise<{
        query: string;
        id: string;
        latitude: number | null;
        longitude: number | null;
        category: string | null;
        location: string | null;
        radiusKm: number | null;
        userId: string;
        filters: import("@prisma/client/runtime/library").JsonValue | null;
        resultsCount: number | null;
        clickedResults: import("@prisma/client/runtime/library").JsonValue | null;
        searchedAt: Date;
    }>;
    saveCraftsman(data: SavedCraftsmanDto): Promise<{
        craftsmanId: string;
        notes: string | null;
        tags: string[];
        userId: string;
        savedAt: Date;
    }>;
    unsaveCraftsman(userId: string, craftsmanId: string): Promise<{
        craftsmanId: string;
        notes: string | null;
        tags: string[];
        userId: string;
        savedAt: Date;
    }>;
    getSavedCraftsmen(userId: string): Promise<({
        craftsman: {
            id: string;
            email: string;
            fullName: string;
            city: string;
            county: string;
            specialties: string[];
            isVerified: boolean;
            averageRating: number;
            totalReviews: number;
            profileImage: string;
            profilePicture: string;
            portfolioPhotos: string[];
            yearsExperience: number;
        };
    } & {
        craftsmanId: string;
        notes: string | null;
        tags: string[];
        userId: string;
        savedAt: Date;
    })[]>;
    isCraftsmanSaved(userId: string, craftsmanId: string): Promise<boolean>;
    updateSavedCraftsman(userId: string, craftsmanId: string, data: {
        notes?: string;
        tags?: string[];
    }): Promise<{
        craftsmanId: string;
        notes: string | null;
        tags: string[];
        userId: string;
        savedAt: Date;
    }>;
    getCraftsmenSaveStats(craftsmanId: string): Promise<{
        craftsmanId: string;
        saveCount: number;
    }>;
    getUserEngagement(userId: string): Promise<{
        totalEvents: number;
        searchCount: number;
        savedCraftsmenCount: number;
        recentActivity: {
            id: string;
            createdAt: Date;
            city: string | null;
            latitude: number | null;
            longitude: number | null;
            eventType: import("@prisma/client").$Enums.AnalyticsEventType;
            userId: string | null;
            platform: string | null;
            sessionId: string | null;
            eventName: string;
            properties: import("@prisma/client/runtime/library").JsonValue | null;
            appVersion: string | null;
            deviceInfo: import("@prisma/client/runtime/library").JsonValue | null;
            ipAddress: string | null;
            userAgent: string | null;
            referrer: string | null;
            country: string | null;
        }[];
    }>;
    getPlatformAnalytics(): Promise<{
        totalUsers: number;
        totalEvents: number;
        totalSearches: number;
        activeUsersLast30Days: number;
        popularSearches: {
            query: string;
            count: number;
        }[];
    }>;
}
