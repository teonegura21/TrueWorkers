import { PrismaService } from '../prisma/prisma.service';
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
export declare class UsersGeoService {
    private prisma;
    constructor(prisma: PrismaService);
    private calculateDistance;
    private toRad;
    searchNearby(params: GeoSearchParams): Promise<{
        craftsmen: {
            distanceKm: number;
            id: string;
            email: string;
            fullName: string;
            city: string;
            county: string;
            latitude: number;
            longitude: number;
            specialties: string[];
            isVerified: boolean;
            averageRating: number;
            totalReviews: number;
            profileImage: string;
            bio: string;
            profilePicture: string;
            portfolioPhotos: string[];
            yearsExperience: number;
            skillsTags: string[];
            certifications: string[];
            insuranceVerified: boolean;
            availability: string;
        }[];
        pagination: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
        };
        searchParams: {
            latitude: number;
            longitude: number;
            radiusKm: number;
        };
    }>;
    updateLocation(userId: string, latitude: number, longitude: number, city?: string, county?: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        email: string;
        firebaseUid: string | null;
        passwordHash: string | null;
        fullName: string;
        role: import("@prisma/client").$Enums.UserRole;
        userType: import("@prisma/client").$Enums.UserType | null;
        city: string;
        county: string;
        address: string | null;
        latitude: number | null;
        longitude: number | null;
        specialties: string[];
        isVerified: boolean;
        averageRating: number;
        totalReviews: number;
        phone: string | null;
        profileImage: string | null;
        bio: string | null;
        rating: number | null;
        reviewCount: number | null;
        profilePicture: string | null;
        portfolioPhotos: string[];
        yearsExperience: number | null;
        skillsTags: string[];
        certifications: string[];
        insuranceVerified: boolean;
        availability: string | null;
    }>;
    getCraftsmenInBounds(northEast: {
        lat: number;
        lng: number;
    }, southWest: {
        lat: number;
        lng: number;
    }): Promise<{
        id: string;
        fullName: string;
        city: string;
        latitude: number;
        longitude: number;
        specialties: string[];
        isVerified: boolean;
        averageRating: number;
        profileImage: string;
    }[]>;
}
