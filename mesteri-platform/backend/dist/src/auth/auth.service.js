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
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let AuthService = class AuthService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async validateUser(email, password) {
        throw new common_1.BadRequestException({
            error: 'DEPRECATED_ENDPOINT',
            message: 'Legacy authentication is deprecated. Please use Firebase Authentication.',
            migration: {
                frontend: 'Use Firebase SDK: firebase.auth().signInWithEmailAndPassword()',
                backend: 'Send Firebase ID token to protected endpoints with Authorization: Bearer <firebase-token>'
            }
        });
    }
    async login(loginUserDto) {
        throw new common_1.BadRequestException({
            error: 'DEPRECATED_ENDPOINT',
            message: 'Legacy login is deprecated. Please use Firebase Authentication.',
            migration: {
                frontend: 'Use Firebase SDK: firebase.auth().signInWithEmailAndPassword()',
                backend: 'Send Firebase ID token to protected endpoints'
            }
        });
    }
    async register(createUserDto) {
        throw new common_1.BadRequestException({
            error: 'DEPRECATED_ENDPOINT',
            message: 'Legacy registration is deprecated. Please use Firebase Authentication.',
            migration: {
                frontend: 'Use Firebase SDK: firebase.auth().createUserWithEmailAndPassword()',
                backend: 'Firebase will automatically sync users via FirebaseService'
            }
        });
    }
    async getProfile(userId) {
        throw new common_1.BadRequestException({
            error: 'DEPRECATED_ENDPOINT',
            message: 'Legacy profile endpoint is deprecated.',
            migration: {
                alternative: 'Use GET /api/users/profile with Firebase token authentication'
            }
        });
    }
    async forgotPassword(forgotPasswordDto) {
        throw new common_1.BadRequestException({
            error: 'DEPRECATED_ENDPOINT',
            message: 'Legacy password reset is deprecated. Please use Firebase Authentication.',
            migration: {
                frontend: 'Use Firebase SDK: firebase.auth().sendPasswordResetEmail()',
                note: 'Firebase handles password reset flow automatically'
            }
        });
    }
    async resetPassword(resetPasswordDto) {
        throw new common_1.BadRequestException({
            error: 'DEPRECATED_ENDPOINT',
            message: 'Legacy password reset is deprecated. Please use Firebase Authentication.',
            migration: {
                frontend: 'Use Firebase SDK password reset flow',
                note: 'Firebase handles password reset confirmation automatically'
            }
        });
    }
    async refreshToken(refreshTokenDto) {
        throw new common_1.BadRequestException({
            error: 'DEPRECATED_ENDPOINT',
            message: 'Legacy token refresh is deprecated. Please use Firebase Authentication.',
            migration: {
                frontend: 'Firebase SDK handles token refresh automatically',
                note: 'No manual token refresh needed with Firebase'
            }
        });
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AuthService);
//# sourceMappingURL=auth.service.js.map