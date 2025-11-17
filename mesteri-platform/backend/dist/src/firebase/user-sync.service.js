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
var UserSyncService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserSyncService = void 0;
const common_1 = require("@nestjs/common");
const firebase_service_1 = require("./firebase.service");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
let UserSyncService = UserSyncService_1 = class UserSyncService {
    firebaseService;
    prisma;
    logger = new common_1.Logger(UserSyncService_1.name);
    constructor(firebaseService, prisma) {
        this.firebaseService = firebaseService;
        this.prisma = prisma;
    }
    async syncUser(userData) {
        try {
            let localUser = await this.prisma.user.findUnique({
                where: { firebaseUid: userData.uid },
            });
            if (localUser) {
                localUser = await this.prisma.user.update({
                    where: { id: localUser.id },
                    data: {
                        email: userData.email,
                        fullName: userData.name || localUser.fullName,
                        phone: userData.phoneNumber || localUser.phone,
                        updatedAt: new Date(),
                    },
                });
                this.logger.log(`Updated existing user: ${userData.email}`);
            }
            else {
                localUser = await this.prisma.user.create({
                    data: {
                        firebaseUid: userData.uid,
                        email: userData.email,
                        fullName: userData.name || 'Unknown User',
                        role: userData.role === 'client' ? client_1.UserRole.CLIENT : client_1.UserRole.CRAFTSMAN,
                        userType: client_1.UserType.INDIVIDUAL,
                        phone: userData.phoneNumber,
                        city: 'Unknown',
                        county: 'Unknown',
                        specialties: [],
                        isVerified: false,
                        averageRating: 5.0,
                        totalReviews: 0,
                    },
                });
                this.logger.log(`Created new user: ${userData.email}`);
                const firestoreProfileData = {
                    localUserId: localUser.id,
                    email: userData.email,
                    name: userData.name || 'Unknown User',
                    role: userData.role,
                    isVerified: false,
                    createdAt: new Date().toISOString(),
                };
                if (userData.phoneNumber) {
                    firestoreProfileData.phoneNumber = userData.phoneNumber;
                }
                await this.firebaseService.createUserProfile(userData.uid, firestoreProfileData);
            }
            return localUser;
        }
        catch (error) {
            this.logger.error(`Failed to sync user ${userData.email}:`, error);
            throw error;
        }
    }
    async getUserByFirebaseUid(firebaseUid) {
        try {
            return await this.prisma.user.findUnique({
                where: { firebaseUid },
            });
        }
        catch (error) {
            this.logger.error(`Failed to get user by Firebase UID ${firebaseUid}:`, error);
            return null;
        }
    }
    async updateUserProfile(firebaseUid, updates) {
        try {
            const user = await this.prisma.user.findUnique({
                where: { firebaseUid },
            });
            if (!user) {
                throw new Error('User not found');
            }
            const updatedUser = await this.prisma.user.update({
                where: { id: user.id },
                data: {
                    email: updates.email || user.email,
                    fullName: updates.name || user.fullName,
                    phone: updates.phoneNumber || user.phone,
                    updatedAt: new Date(),
                },
            });
            this.logger.log(`Updated user profile: ${updatedUser.email}`);
            return updatedUser;
        }
        catch (error) {
            this.logger.error(`Failed to update user profile ${firebaseUid}:`, error);
            throw error;
        }
    }
    async deleteUser(firebaseUid) {
        try {
            await this.prisma.user.delete({
                where: { firebaseUid },
            });
            await this.firebaseService.deleteUser(firebaseUid);
            this.logger.log(`Deleted user: ${firebaseUid}`);
        }
        catch (error) {
            this.logger.error(`Failed to delete user ${firebaseUid}:`, error);
            throw error;
        }
    }
    async getCompleteUserProfile(firebaseUid) {
        try {
            const localUser = await this.getUserByFirebaseUid(firebaseUid);
            if (!localUser) {
                return null;
            }
            const firebaseUser = await this.firebaseService.getUserByUid(firebaseUid);
            const firestoreProfile = await this.firebaseService.getDocument('users', firebaseUid);
            return {
                local: localUser,
                firebase: {
                    uid: firebaseUser.uid,
                    email: firebaseUser.email,
                    displayName: firebaseUser.displayName,
                    emailVerified: firebaseUser.emailVerified,
                    phoneNumber: firebaseUser.phoneNumber,
                    customClaims: firebaseUser.customClaims,
                },
                firestore: firestoreProfile,
            };
        }
        catch (error) {
            this.logger.error(`Failed to get complete user profile ${firebaseUid}:`, error);
            return null;
        }
    }
};
exports.UserSyncService = UserSyncService;
exports.UserSyncService = UserSyncService = UserSyncService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [firebase_service_1.FirebaseService,
        prisma_service_1.PrismaService])
], UserSyncService);
//# sourceMappingURL=user-sync.service.js.map