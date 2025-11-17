import { PrismaService } from '../prisma/prisma.service';
import { User, UserRole } from '@prisma/client';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
export type { User };
export declare class UsersService {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(): Promise<User[]>;
    findOne(id: string): Promise<User>;
    findByEmail(email: string): Promise<User | null>;
    findByRole(role: UserRole): Promise<User[]>;
    create(createUserDto: CreateUserDto): Promise<User>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<User>;
    delete(id: string): Promise<void>;
    search(query: string, filters?: {
        role?: UserRole;
        isVerified?: boolean;
        page?: number;
        limit?: number;
    }): Promise<{
        users: User[];
        total: number;
    }>;
    getCraftsmenWithSpecialty(specialty?: string, filters?: {
        isVerified?: boolean;
        minRating?: number;
        city?: string;
        page?: number;
        limit?: number;
    }): Promise<{
        craftsmen: User[];
        total: number;
    }>;
}
