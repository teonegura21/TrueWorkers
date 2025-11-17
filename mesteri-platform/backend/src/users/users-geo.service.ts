import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole } from '@prisma/client';

export interface GeoSearchParams {
  latitude: number;
  longitude: number;
  radiusKm?: number;
  specialty?: string;
  minRating?: number;
  isVerified?: boolean;
  page?: number;
  limit?: number;
}

@Injectable()
export class UsersGeoService {
  constructor(private prisma: PrismaService) {}

  /**
   * Calculate distance between two GPS points using Haversine formula
   * Returns distance in kilometers
   */
  private calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number,
  ): number {
    const R = 6371; // Earth's radius in km
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) *
        Math.cos(this.toRad(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private toRad(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  /**
   * Search for craftsmen near a location
   */
  async searchNearby(params: GeoSearchParams) {
    const {
      latitude,
      longitude,
      radiusKm = 50,
      specialty,
      minRating,
      isVerified,
      page = 1,
      limit = 20,
    } = params;

    // Get all craftsmen (we'll filter by distance in-memory for now)
    // TODO: In production, use PostGIS for database-level geo queries
    const where: any = {
      role: UserRole.CRAFTSMAN,
      latitude: { not: null },
      longitude: { not: null },
    };

    if (specialty) {
      where.specialties = { has: specialty };
    }

    if (minRating !== undefined) {
      where.averageRating = { gte: minRating };
    }

    if (isVerified !== undefined) {
      where.isVerified = isVerified;
    }

    const craftsmen = await this.prisma.user.findMany({
      where,
      select: {
        id: true,
        fullName: true,
        email: true,
        city: true,
        county: true,
        latitude: true,
        longitude: true,
        profileImage: true,
        profilePicture: true,
        bio: true,
        specialties: true,
        averageRating: true,
        totalReviews: true,
        isVerified: true,
        yearsExperience: true,
        skillsTags: true,
        portfolioPhotos: true,
        certifications: true,
        insuranceVerified: true,
        availability: true,
      },
    });

    // Calculate distance for each craftsman
    const craftsmenWithDistance = craftsmen
      .map((craftsman) => {
        const distance = this.calculateDistance(
          latitude,
          longitude,
          craftsman.latitude,
          craftsman.longitude,
        );

        return {
          ...craftsman,
          distanceKm: Math.round(distance * 10) / 10, // Round to 1 decimal
        };
      })
      .filter((craftsman) => craftsman.distanceKm <= radiusKm)
      .sort((a, b) => a.distanceKm - b.distanceKm); // Sort by distance

    // Paginate
    const skip = (page - 1) * limit;
    const paginatedResults = craftsmenWithDistance.slice(skip, skip + limit);

    return {
      craftsmen: paginatedResults,
      pagination: {
        page,
        limit,
        total: craftsmenWithDistance.length,
        totalPages: Math.ceil(craftsmenWithDistance.length / limit),
      },
      searchParams: {
        latitude,
        longitude,
        radiusKm,
      },
    };
  }

  /**
   * Update user location
   */
  async updateLocation(
    userId: string,
    latitude: number,
    longitude: number,
    city?: string,
    county?: string,
  ) {
    return this.prisma.user.update({
      where: { id: userId },
      data: {
        latitude,
        longitude,
        ...(city && { city }),
        ...(county && { county }),
      },
    });
  }

  /**
   * Get craftsmen within bounding box (for map view)
   */
  async getCraftsmenInBounds(
    northEast: { lat: number; lng: number },
    southWest: { lat: number; lng: number },
  ) {
    return this.prisma.user.findMany({
      where: {
        role: UserRole.CRAFTSMAN,
        latitude: {
          gte: southWest.lat,
          lte: northEast.lat,
        },
        longitude: {
          gte: southWest.lng,
          lte: northEast.lng,
        },
      },
      select: {
        id: true,
        fullName: true,
        latitude: true,
        longitude: true,
        city: true,
        averageRating: true,
        specialties: true,
        profileImage: true,
        isVerified: true,
      },
    });
  }
}
