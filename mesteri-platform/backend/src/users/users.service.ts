import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { User, UserRole, UserType } from '@prisma/client';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import * as bcrypt from 'bcrypt';  // Only used for seeding/testing - production users are created via Firebase

export type { User };

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findAll(): Promise<User[]> {
    return this.prisma.user.findMany({
      include: {
        postedJobs: true,
        offers: true,
        receivedReviews: true,
        sentMessages: true,
        notifications: true,
      },
    });
  }

  async findOne(id: string): Promise<User> {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        postedJobs: true,
        offers: true,
        receivedReviews: true,
        sentMessages: true,
        notifications: true,
      },
    });
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { email },
      include: {
        postedJobs: true,
        offers: true,
        receivedReviews: true,
        sentMessages: true,
        notifications: true,
      },
    });
  }

  async findByRole(role: UserRole): Promise<User[]> {
    return this.prisma.user.findMany({
      where: { role },
      include: {
        postedJobs: true,
        offers: true,
        receivedReviews: true,
        sentMessages: true,
        notifications: true,
      },
    });
  }

  async create(createUserDto: CreateUserDto): Promise<User> {
    // DEPRECATED: Password hashing only used for seeding/testing
    // In production, users are created via Firebase and synchronized automatically
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(
      createUserDto.password,
      saltRounds,
    );

    // Map DTO fields to Prisma schema fields
    const role =
      createUserDto.role === 'master' ? UserRole.CRAFTSMAN : UserRole.CLIENT;

    return this.prisma.user.create({
      data: {
        email: createUserDto.email,
        passwordHash: hashedPassword,
        fullName: `${createUserDto.firstName} ${createUserDto.lastName}`,
        role,
        userType: UserType.INDIVIDUAL, // Default user type
        county: 'Desconocido', // Default county since DTO doesn't provide it
        city: createUserDto.location, // Map location to city
        specialties: createUserDto.specialty ? [createUserDto.specialty] : [],
      },
    });
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    try {
      return await this.prisma.user.update({
        where: { id },
        data: updateUserDto,
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`User with ID ${id} not found`);
      }
      throw error;
    }
  }

  async delete(id: string): Promise<void> {
    try {
      await this.prisma.user.delete({
        where: { id },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`User with ID ${id} not found`);
      }
      throw error;
    }
  }

  async search(
    query: string,
    filters?: {
      role?: UserRole;
      isVerified?: boolean;
      page?: number;
      limit?: number;
    },
  ): Promise<{ users: User[]; total: number }> {
    const skip =
      filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
    const take = filters?.limit || 10;

    const where: any = {
      ...(filters?.role && { role: filters.role }),
      ...(filters?.isVerified !== undefined && {
        isVerified: filters.isVerified,
      }),
      ...(query && {
        OR: [
          { fullName: { contains: query, mode: 'insensitive' } },
          { email: { contains: query, mode: 'insensitive' } },
        ],
      }),
    };

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take,
      }),
      this.prisma.user.count({ where }),
    ]);

    return { users, total };
  }

  async getCraftsmenWithSpecialty(
    specialty?: string,
    filters?: {
      isVerified?: boolean;
      minRating?: number;
      city?: string;
      page?: number;
      limit?: number;
    },
  ): Promise<{ craftsmen: User[]; total: number }> {
    const skip =
      filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
    const take = filters?.limit || 10;

    const where = {
      role: UserRole.CRAFTSMAN,
      ...(filters?.isVerified !== undefined && {
        isVerified: filters.isVerified,
      }),
      ...(filters?.minRating && { averageRating: { gte: filters.minRating } }),
      ...(filters?.city && { city: filters.city }),
      ...(specialty && {
        specialties: {
          has: specialty,
        },
      }),
    };

    const [craftsmen, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take,
        orderBy: [
          { isVerified: 'desc' },
          { averageRating: 'desc' },
          { totalReviews: 'desc' },
        ],
      }),
      this.prisma.user.count({ where }),
    ]);

    return { craftsmen, total };
  }
}
