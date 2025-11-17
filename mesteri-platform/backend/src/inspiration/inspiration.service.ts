import { Injectable, NotFoundException } from '@nestjs/common';
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

@Injectable()
export class InspirationService {
  constructor(private prisma: PrismaService) {}

  async findAll(
    filters?: {
      craftsmanId?: string;
      city?: string;
      skill?: string;
      isPromoted?: boolean;
      page?: number;
      limit?: number;
    },
  ): Promise<{ posts: InspirationPost[]; total: number }> {
    const skip = filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
    const take = filters?.limit || 20;

    const where: any = {
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

  async findOne(id: string): Promise<InspirationPost> {
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
      throw new NotFoundException(`Inspiration post with ID ${id} not found`);
    }

    // Increment view count
    await this.prisma.inspirationPost.update({
      where: { id },
      data: { views: { increment: 1 } },
    });

    return post;
  }

  async create(createDto: CreateInspirationPostDto): Promise<InspirationPost> {
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

  async update(id: string, updateDto: UpdateInspirationPostDto): Promise<InspirationPost> {
    try {
      return await this.prisma.inspirationPost.update({
        where: { id },
        data: updateDto,
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Inspiration post with ID ${id} not found`);
      }
      throw error;
    }
  }

  async delete(id: string): Promise<void> {
    try {
      await this.prisma.inspirationPost.delete({
        where: { id },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Inspiration post with ID ${id} not found`);
      }
      throw error;
    }
  }

  async incrementLikes(id: string): Promise<InspirationPost> {
    return this.prisma.inspirationPost.update({
      where: { id },
      data: { likes: { increment: 1 } },
    });
  }

  async incrementShares(id: string): Promise<InspirationPost> {
    return this.prisma.inspirationPost.update({
      where: { id },
      data: { shares: { increment: 1 } },
    });
  }

  async getFeed(
    userId?: string,
    page: number = 1,
    limit: number = 20,
  ): Promise<{ posts: InspirationPost[]; total: number }> {
    // TikTok-style feed: prioritize promoted, then by engagement
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
}
