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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FirebaseAuthController = void 0;
const common_1 = require("@nestjs/common");
const firebase_service_1 = require("../firebase/firebase.service");
const user_sync_service_1 = require("../firebase/user-sync.service");
const auth_decorators_1 = require("../decorators/auth.decorators");
let FirebaseAuthController = class FirebaseAuthController {
    firebaseService;
    userSyncService;
    constructor(firebaseService, userSyncService) {
        this.firebaseService = firebaseService;
        this.userSyncService = userSyncService;
    }
    async setUserRole(setRoleDto) {
        const { uid, role, email, name } = setRoleDto;
        try {
            await this.firebaseService.setCustomClaims(uid, role);
            await this.firebaseService.createUserProfile(uid, {
                uid,
                email: email || '',
                name: name || '',
                role,
                roleValue: role === 'client' ? 0 : 1,
                isVerified: false,
                rating: 0.0,
                completedProjects: 0,
                createdAt: new Date(),
                updatedAt: new Date(),
            });
            return {
                success: true,
                message: `Role ${role} assigned successfully`,
                uid,
                role,
                roleValue: role === 'client' ? 0 : 1,
            };
        }
        catch (error) {
            throw new common_1.InternalServerErrorException(`Failed to set user role: ${error.message}`);
        }
    }
    async getUserClaims({ uid }) {
        try {
            const userRecord = await this.firebaseService.getUserByUid(uid);
            return {
                uid: userRecord.uid,
                email: userRecord.email,
                customClaims: userRecord.customClaims || {},
                disabled: userRecord.disabled,
                emailVerified: userRecord.emailVerified,
            };
        }
        catch (error) {
            throw new common_1.BadRequestException(`Failed to get user claims: ${error.message}`);
        }
    }
    async verifyToken({ idToken }) {
        try {
            const decodedToken = await this.firebaseService.verifyIdToken(idToken);
            return {
                uid: decodedToken.uid,
                email: decodedToken.email,
                role: decodedToken.role,
                roleValue: decodedToken.roleValue,
                emailVerified: decodedToken.email_verified,
            };
        }
        catch (error) {
            throw new common_1.BadRequestException(`Invalid token: ${error.message}`);
        }
    }
    async syncUser(userData) {
        try {
            const localUser = await this.userSyncService.syncUser(userData);
            return {
                success: true,
                user: {
                    id: localUser.id,
                    firebaseUid: localUser.firebaseUid,
                    email: localUser.email,
                    fullName: localUser.fullName,
                    role: localUser.role,
                    isVerified: localUser.isVerified,
                },
            };
        }
        catch (error) {
            throw new common_1.InternalServerErrorException(`User synchronization failed: ${error.message}`);
        }
    }
    async getProfile({ uid }) {
        try {
            const profile = await this.userSyncService.getCompleteUserProfile(uid);
            if (!profile) {
                throw new common_1.BadRequestException('User not found');
            }
            return {
                success: true,
                profile,
            };
        }
        catch (error) {
            throw new common_1.BadRequestException(`Failed to get profile: ${error.message}`);
        }
    }
};
exports.FirebaseAuthController = FirebaseAuthController;
__decorate([
    (0, auth_decorators_1.Public)(),
    (0, common_1.Post)('set-role'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], FirebaseAuthController.prototype, "setUserRole", null);
__decorate([
    (0, auth_decorators_1.Public)(),
    (0, common_1.Post)('get-user-claims'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], FirebaseAuthController.prototype, "getUserClaims", null);
__decorate([
    (0, auth_decorators_1.Public)(),
    (0, common_1.Post)('verify-token'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], FirebaseAuthController.prototype, "verifyToken", null);
__decorate([
    (0, auth_decorators_1.Public)(),
    (0, common_1.Post)('sync-user'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], FirebaseAuthController.prototype, "syncUser", null);
__decorate([
    (0, auth_decorators_1.Public)(),
    (0, common_1.Post)('get-profile'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], FirebaseAuthController.prototype, "getProfile", null);
exports.FirebaseAuthController = FirebaseAuthController = __decorate([
    (0, common_1.Controller)('firebase-auth'),
    __metadata("design:paramtypes", [firebase_service_1.FirebaseService,
        user_sync_service_1.UserSyncService])
], FirebaseAuthController);
//# sourceMappingURL=firebase-auth.controller.js.map