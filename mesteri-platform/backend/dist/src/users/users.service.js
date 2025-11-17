"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UsersService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
const bcrypt = __importStar(require("bcrypt"));
let UsersService = class UsersService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll() {
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
    async findOne(id) {
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
            throw new common_1.NotFoundException(`User with ID ${id} not found`);
        }
        return user;
    }
    async findByEmail(email) {
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
    async findByRole(role) {
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
    async create(createUserDto) {
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(createUserDto.password, saltRounds);
        const role = createUserDto.role === 'master' ? client_1.UserRole.CRAFTSMAN : client_1.UserRole.CLIENT;
        return this.prisma.user.create({
            data: {
                email: createUserDto.email,
                passwordHash: hashedPassword,
                fullName: `${createUserDto.firstName} ${createUserDto.lastName}`,
                role,
                userType: client_1.UserType.INDIVIDUAL,
                county: 'Desconocido',
                city: createUserDto.location,
                specialties: createUserDto.specialty ? [createUserDto.specialty] : [],
            },
        });
    }
    async update(id, updateUserDto) {
        try {
            return await this.prisma.user.update({
                where: { id },
                data: updateUserDto,
            });
        }
        catch (error) {
            if (error.code === 'P2025') {
                throw new common_1.NotFoundException(`User with ID ${id} not found`);
            }
            throw error;
        }
    }
    async delete(id) {
        try {
            await this.prisma.user.delete({
                where: { id },
            });
        }
        catch (error) {
            if (error.code === 'P2025') {
                throw new common_1.NotFoundException(`User with ID ${id} not found`);
            }
            throw error;
        }
    }
    async search(query, filters) {
        const skip = filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
        const take = filters?.limit || 10;
        const where = {
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
    async getCraftsmenWithSpecialty(specialty, filters) {
        const skip = filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
        const take = filters?.limit || 10;
        const where = {
            role: client_1.UserRole.CRAFTSMAN,
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
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], UsersService);
//# sourceMappingURL=users.service.js.map