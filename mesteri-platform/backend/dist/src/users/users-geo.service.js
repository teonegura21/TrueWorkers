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
exports.UsersGeoService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
let UsersGeoService = class UsersGeoService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    calculateDistance(lat1, lon1, lat2, lon2) {
        const R = 6371;
        const dLat = this.toRad(lat2 - lat1);
        const dLon = this.toRad(lon2 - lon1);
        const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(this.toRad(lat1)) *
                Math.cos(this.toRad(lat2)) *
                Math.sin(dLon / 2) *
                Math.sin(dLon / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
    toRad(degrees) {
        return degrees * (Math.PI / 180);
    }
    async searchNearby(params) {
        const { latitude, longitude, radiusKm = 50, specialty, minRating, isVerified, page = 1, limit = 20, } = params;
        const where = {
            role: client_1.UserRole.CRAFTSMAN,
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
        const craftsmenWithDistance = craftsmen
            .map((craftsman) => {
            const distance = this.calculateDistance(latitude, longitude, craftsman.latitude, craftsman.longitude);
            return {
                ...craftsman,
                distanceKm: Math.round(distance * 10) / 10,
            };
        })
            .filter((craftsman) => craftsman.distanceKm <= radiusKm)
            .sort((a, b) => a.distanceKm - b.distanceKm);
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
    async updateLocation(userId, latitude, longitude, city, county) {
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
    async getCraftsmenInBounds(northEast, southWest) {
        return this.prisma.user.findMany({
            where: {
                role: client_1.UserRole.CRAFTSMAN,
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
};
exports.UsersGeoService = UsersGeoService;
exports.UsersGeoService = UsersGeoService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], UsersGeoService);
//# sourceMappingURL=users-geo.service.js.map