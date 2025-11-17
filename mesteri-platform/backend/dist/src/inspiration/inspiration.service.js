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
exports.InspirationService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let InspirationService = class InspirationService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll(filters) {
        const skip = filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
        const take = filters?.limit || 20;
        const where = {
            isPublished: true,
            ...(filters?.craftsmanId && { craftsmanId: filters.craftsmanId }),
            ...(filters?.city && { city: filters.city }),
            ...(filters?.isPromoted !== undefined && { isPromoted: filters.isPromoted }),
            ...(filters?.skill && {
                skillsShowcased: {
                    has: filters.skill,
                },
            }),
        };
        const [posts, total] = await Promise.all([
            this.prisma.inspirationPost.findMany({
                where,
                skip,
                take,
                include: {
                    craftsman: {
                        select: {
                            id: true,
                            fullName: true,
                            profilePicture: true,
                            averageRating: true,
                            totalReviews: true,
                            isVerified: true,
                            city: true,
                        },
                    },
                },
                orderBy: [
                    { isPinned: 'desc' },
                    { isPromoted: 'desc' },
                    { createdAt: 'desc' },
                ],
            }),
            this.prisma.inspirationPost.count({ where }),
        ]);
        return { posts, total };
    }
    async findOne(id) {
        const post = await this.prisma.inspirationPost.findUnique({
            where: { id },
            include: {
                craftsman: {
                    select: {
                        id: true,
                        fullName: true,
                        profilePicture: true,
                        averageRating: true,
                        totalReviews: true,
                        isVerified: true,
                        city: true,
                        specialties: true,
                        yearsExperience: true,
                    },
                },
            },
        });
        if (!post) {
            throw new common_1.NotFoundException(`Inspiration post with ID ${id} not found`);
        }
        await this.prisma.inspirationPost.update({
            where: { id },
            data: { views: { increment: 1 } },
        });
        return post;
    }
    async create(createDto) {
        return this.prisma.inspirationPost.create({
            data: {
                ...createDto,
                additionalPhotos: createDto.additionalPhotos || [],
                skillsShowcased: createDto.skillsShowcased || [],
            },
            include: {
                craftsman: {
                    select: {
                        id: true,
                        fullName: true,
                        profilePicture: true,
                        city: true,
                    },
                },
            },
        });
    }
    async update(id, updateDto) {
        try {
            return await this.prisma.inspirationPost.update({
                where: { id },
                data: updateDto,
            });
        }
        catch (error) {
            if (error.code === 'P2025') {
                throw new common_1.NotFoundException(`Inspiration post with ID ${id} not found`);
            }
            throw error;
        }
    }
    async delete(id) {
        try {
            await this.prisma.inspirationPost.delete({
                where: { id },
            });
        }
        catch (error) {
            if (error.code === 'P2025') {
                throw new common_1.NotFoundException(`Inspiration post with ID ${id} not found`);
            }
            throw error;
        }
    }
    async incrementLikes(id) {
        return this.prisma.inspirationPost.update({
            where: { id },
            data: { likes: { increment: 1 } },
        });
    }
    async incrementShares(id) {
        return this.prisma.inspirationPost.update({
            where: { id },
            data: { shares: { increment: 1 } },
        });
    }
    async getFeed(userId, page = 1, limit = 20) {
        const skip = (page - 1) * limit;
        const [posts, total] = await Promise.all([
            this.prisma.inspirationPost.findMany({
                where: {
                    isPublished: true,
                },
                skip,
                take: limit,
                include: {
                    craftsman: {
                        select: {
                            id: true,
                            fullName: true,
                            profilePicture: true,
                            averageRating: true,
                            totalReviews: true,
                            isVerified: true,
                            city: true,
                        },
                    },
                },
                orderBy: [
                    { isPinned: 'desc' },
                    { isPromoted: 'desc' },
                    { likes: 'desc' },
                    { views: 'desc' },
                    { createdAt: 'desc' },
                ],
            }),
            this.prisma.inspirationPost.count({
                where: { isPublished: true },
            }),
        ]);
        return { posts, total };
    }
};
exports.InspirationService = InspirationService;
exports.InspirationService = InspirationService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], InspirationService);
//# sourceMappingURL=inspiration.service.js.map