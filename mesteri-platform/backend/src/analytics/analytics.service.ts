import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export type AnalyticsEventType =
  | 'PAGE_VIEW'
  | 'SEARCH'
  | 'PROFILE_VIEW'
  | 'JOB_POST'
  | 'OFFER_SUBMIT'
  | 'MESSAGE_SENT'
  | 'REVIEW_SUBMIT'
  | 'PAYMENT_INITIATED'
  | 'PAYMENT_COMPLETED'
  | 'CONTRACT_SIGNED'
  | 'PROJECT_CREATED'
  | 'INSPIRATION_VIEW'
  | 'INSPIRATION_LIKE'
  | 'CRAFTSMAN_CONTACT'
  | 'APP_OPEN'
  | 'APP_CLOSE'
  | 'FEATURE_USED';

export interface TrackEventDto {
  userId?: string;
  sessionId?: string;
  eventType: AnalyticsEventType;
  eventName: string;
  properties?: any;
  platform?: string;
  appVersion?: string;
  deviceInfo?: any;
  ipAddress?: string;
  userAgent?: string;
  referrer?: string;
  latitude?: number;
  longitude?: number;
  city?: string;
  country?: string;
}

export interface SearchHistoryDto {
  userId: string;
  query: string;
  filters?: any;
  category?: string;
  location?: string;
  latitude?: number;
  longitude?: number;
  radiusKm?: number;
  resultsCount?: number;
  clickedResults?: string[];
}

export interface SavedCraftsmanDto {
  userId: string;
  craftsmanId: string;
  notes?: string;
  tags?: string[];
}

@Injectable()
export class AnalyticsService {
  constructor(private prisma: PrismaService) {}

  // ========== ANALYTICS EVENTS ==========

  /**
   * Track a user event
   */
  async trackEvent(data: TrackEventDto) {
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

  /**
   * Get user events
   */
  async getUserEvents(userId: string, limit: number = 100) {
    return this.prisma.analyticsEvent.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  /**
   * Get events by type
   */
  async getEventsByType(eventType: AnalyticsEventType, limit: number = 100) {
    return this.prisma.analyticsEvent.findMany({
      where: { eventType },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  /**
   * Get events in time range
   */
  async getEventsInRange(startDate: Date, endDate: Date) {
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

  /**
   * Get event statistics
   */
  async getEventStats(userId?: string) {
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

  // ========== SEARCH HISTORY ==========

  /**
   * Record a search
   */
  async recordSearch(data: SearchHistoryDto) {
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

  /**
   * Get user search history
   */
  async getUserSearchHistory(userId: string, limit: number = 50) {
    return this.prisma.searchHistory.findMany({
      where: { userId },
      orderBy: { searchedAt: 'desc' },
      take: limit,
    });
  }

  /**
   * Get popular searches
   */
  async getPopularSearches(limit: number = 10) {
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

  /**
   * Get search suggestions based on history
   */
  async getSearchSuggestions(userId: string, partialQuery: string, limit: number = 5) {
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

  /**
   * Clear user search history
   */
  async clearSearchHistory(userId: string) {
    return this.prisma.searchHistory.deleteMany({
      where: { userId },
    });
  }

  /**
   * Update search with clicked results
   */
  async recordSearchClick(searchId: string, resultId: string) {
    const search = await this.prisma.searchHistory.findUnique({
      where: { id: searchId },
    });

    if (!search) return null;

    const clickedResults = (search.clickedResults as string[]) || [];
    if (!clickedResults.includes(resultId)) {
      clickedResults.push(resultId);
    }

    return this.prisma.searchHistory.update({
      where: { id: searchId },
      data: { clickedResults },
    });
  }

  // ========== SAVED CRAFTSMEN ==========

  /**
   * Save a craftsman to favorites
   */
  async saveCraftsman(data: SavedCraftsmanDto) {
    return this.prisma.savedCraftsman.create({
      data: {
        userId: data.userId,
        craftsmanId: data.craftsmanId,
        notes: data.notes,
        tags: data.tags || [],
      },
    });
  }

  /**
   * Remove a saved craftsman
   */
  async unsaveCraftsman(userId: string, craftsmanId: string) {
    return this.prisma.savedCraftsman.delete({
      where: {
        userId_craftsmanId: {
          userId,
          craftsmanId,
        },
      },
    });
  }

  /**
   * Get user's saved craftsmen
   */
  async getSavedCraftsmen(userId: string) {
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

  /**
   * Check if craftsman is saved
   */
  async isCraftsmanSaved(userId: string, craftsmanId: string) {
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

  /**
   * Update saved craftsman notes/tags
   */
  async updateSavedCraftsman(
    userId: string,
    craftsmanId: string,
    data: { notes?: string; tags?: string[] },
  ) {
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

  /**
   * Get craftsmen saved by count (popularity)
   */
  async getCraftsmenSaveStats(craftsmanId: string) {
    const count = await this.prisma.savedCraftsman.count({
      where: { craftsmanId },
    });

    return { craftsmanId, saveCount: count };
  }

  // ========== ANALYTICS DASHBOARDS ==========

  /**
   * Get user engagement metrics
   */
  async getUserEngagement(userId: string) {
    const [
      totalEvents,
      searchCount,
      savedCraftsmenCount,
      recentActivity,
    ] = await Promise.all([
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

  /**
   * Get platform-wide analytics
   */
  async getPlatformAnalytics() {
    const now = new Date();
    const last30Days = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    const [
      totalUsers,
      totalEvents,
      totalSearches,
      activeUsers,
      popularSearches,
    ] = await Promise.all([
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
}
