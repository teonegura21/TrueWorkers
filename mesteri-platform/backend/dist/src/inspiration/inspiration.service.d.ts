import { PrismaService } from '../prisma/prisma.service';
import { InspirationPost } from '@prisma/client';
export interface CreateInspirationPostDto {
    craftsmanId: string;
    title: string;
    description: string;
    beforePhoto?: string;
    afterPhoto: string;
    additionalPhotos?: string[];
    videoUrl?: string;
    skillsShowcased: string[];
    category?: string;
    location: string;
    city: string;
    isPromoted?: boolean;
    promotionEnds?: Date;
    promotionBudget?: number;
}
export interface UpdateInspirationPostDto {
    title?: string;
    description?: string;
    skillsShowcased?: string[];
    isPublished?: boolean;
    isPinned?: boolean;
}
export declare class InspirationService {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(filters?: {
        craftsmanId?: string;
        city?: string;
        skill?: string;
        isPromoted?: boolean;
        page?: number;
        limit?: number;
    }): Promise<{
        posts: InspirationPost[];
        total: number;
    }>;
    findOne(id: string): Promise<InspirationPost>;
    create(createDto: CreateInspirationPostDto): Promise<InspirationPost>;
    update(id: string, updateDto: UpdateInspirationPostDto): Promise<InspirationPost>;
    delete(id: string): Promise<void>;
    incrementLikes(id: string): Promise<InspirationPost>;
    incrementShares(id: string): Promise<InspirationPost>;
    getFeed(userId?: string, page?: number, limit?: number): Promise<{
        posts: InspirationPost[];
        total: number;
    }>;
}
