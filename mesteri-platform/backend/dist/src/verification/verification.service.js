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
exports.VerificationService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
let VerificationService = class VerificationService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll() {
        return this.prisma.verificationRequest.findMany();
    }
    async findOne(id) {
        return this.prisma.verificationRequest.findUnique({ where: { id } });
    }
    async findByUserId(userId) {
        return this.prisma.verificationRequest.findMany({ where: { userId } });
    }
    async findByType(type) {
        return this.prisma.verificationRequest.findMany({ where: { type: type } });
    }
    async findByStatus(status) {
        return this.prisma.verificationRequest.findMany({ where: { status: status } });
    }
    async create(verificationData) {
        return this.prisma.verificationRequest.create({
            data: {
                ...verificationData,
                submittedAt: new Date(),
                status: client_1.VerificationRequestStatus.PENDING,
            },
        });
    }
    async update(id, updateData) {
        return this.prisma.verificationRequest.update({
            where: { id },
            data: { ...updateData, reviewedAt: new Date() },
        });
    }
    async delete(id) {
        return this.prisma.verificationRequest.delete({ where: { id } });
    }
    async submitForReview(id) {
        const request = await this.prisma.verificationRequest.findUnique({ where: { id } });
        if (!request || request.status !== client_1.VerificationRequestStatus.PENDING) {
            return null;
        }
        return this.prisma.verificationRequest.update({
            where: { id },
            data: { status: client_1.VerificationRequestStatus.IN_REVIEW, reviewedAt: new Date() },
        });
    }
    async approveRequest(id, reviewerid, notes) {
        const request = await this.prisma.verificationRequest.findUnique({ where: { id } });
        if (!request || (request.status !== client_1.VerificationRequestStatus.IN_REVIEW && request.status !== client_1.VerificationRequestStatus.PENDING)) {
            return null;
        }
        const updatedRequest = await this.prisma.verificationRequest.update({
            where: { id },
            data: {
                status: client_1.VerificationRequestStatus.APPROVED,
                approvedAt: new Date(),
                reviewerId: reviewerid,
                notes,
                expiresAt: new Date(new Date().setFullYear(new Date().getFullYear() + 1)),
            },
        });
        await this.awardVerificationBadges(updatedRequest.userId, updatedRequest.type);
        return updatedRequest;
    }
    async rejectRequest(id, reviewerid, reason) {
        const request = await this.prisma.verificationRequest.findUnique({ where: { id } });
        if (!request || (request.status !== client_1.VerificationRequestStatus.IN_REVIEW && request.status !== client_1.VerificationRequestStatus.PENDING)) {
            return null;
        }
        return this.prisma.verificationRequest.update({
            where: { id },
            data: { status: client_1.VerificationRequestStatus.REJECTED, rejectedAt: new Date(), reviewerId: reviewerid, rejectionReason: reason },
        });
    }
    async addDocument(requestid, documentData) {
        return this.prisma.document.create({
            data: {
                ...documentData,
                verificationRequestId: requestid,
                uploadedAt: new Date(),
                status: client_1.DocumentStatus.UPLOADED,
            },
        });
    }
    async verifyDocument(documentid) {
        return this.prisma.document.update({
            where: { id: documentid },
            data: { status: client_1.DocumentStatus.VERIFIED, verifiedAt: new Date() },
        });
    }
    async rejectDocument(documentid, reason) {
        return this.prisma.document.update({
            where: { id: documentid },
            data: { status: client_1.VerificationRequestStatus.REJECTED, rejectedAt: new Date(), rejectionReason: reason },
        });
    }
    async awardVerificationBadges(userId, verificationType) {
        const badgeTypes = this.getBadgeTypesForVerification(verificationType);
        for (const badgeType of badgeTypes) {
            const existingBadge = await this.prisma.verificationBadge.findFirst({
                where: { userId, type: badgeType.type },
            });
            if (!existingBadge) {
                await this.prisma.verificationBadge.create({
                    data: {
                        userId,
                        type: badgeType.type,
                        name: badgeType.name || '',
                        description: badgeType.description || '',
                        icon: badgeType.icon || '',
                        awardedAt: new Date(),
                        isActive: true,
                    },
                });
            }
            else {
                await this.prisma.verificationBadge.update({
                    where: { id: existingBadge.id },
                    data: { isActive: true, awardedAt: new Date() },
                });
            }
        }
    }
    getBadgeTypesForVerification(verificationType) {
        const badgeMap = {
            identity: [
                {
                    type: client_1.DocumentStatus.VERIFIED,
                    name: 'Cont Verificat',
                    description: 'Identitate verificată',
                    icon: client_1.DocumentStatus.VERIFIED,
                },
            ],
            business: [
                {
                    type: client_1.DocumentStatus.VERIFIED,
                    name: 'Cont Verificat',
                    description: 'Identitate verificată',
                    icon: client_1.DocumentStatus.VERIFIED,
                },
            ],
            skill: [
                {
                    type: 'expert',
                    name: 'Expert În Domeniu',
                    description: 'Calificări verificate',
                    icon: 'award',
                },
            ],
            insurance: [
                {
                    type: 'trusted',
                    name: 'Meșter Asigurat',
                    description: 'Asigurare activă',
                    icon: 'shield',
                },
            ],
        };
        return badgeMap[verificationType] || [];
    }
    async getUserBadges(userId) {
        return this.prisma.verificationBadge.findMany({
            where: { userId, isActive: true },
        });
    }
    async getAllBadges() {
        return this.prisma.verificationBadge.findMany();
    }
    async getBadgeById(id) {
        return this.prisma.verificationBadge.findUnique({ where: { id } });
    }
    async getUserVerificationStatus(userId) {
        const userBadges = await this.getUserBadges(userId);
        const isVerified = userBadges.some((b) => b.type === client_1.DocumentStatus.VERIFIED);
        let verificationLevel = 'basic';
        if (userBadges.some((b) => b.type === 'premium')) {
            verificationLevel = 'premium';
        }
        else if (isVerified) {
            verificationLevel = client_1.DocumentStatus.VERIFIED;
        }
        const expiringSoon = userBadges.some((badge) => badge.expiresAt &&
            new Date(badge.expiresAt) <
                new Date(Date.now() + 30 * 24 * 60 * 60 * 1000));
        return {
            isVerified,
            verificationLevel,
            badges: userBadges,
            expiringSoon,
        };
    }
    async getPendingVerifications() {
        return this.prisma.verificationRequest.findMany({
            where: { OR: [{ status: client_1.VerificationRequestStatus.PENDING }, { status: client_1.VerificationRequestStatus.IN_REVIEW }] },
        });
    }
    async getApprovedVerifications() {
        return this.prisma.verificationRequest.findMany({ where: { status: client_1.VerificationRequestStatus.APPROVED } });
    }
    async getRejectedVerifications() {
        return this.prisma.verificationRequest.findMany({ where: { status: client_1.VerificationRequestStatus.REJECTED } });
    }
    async getUserVerificationRequests(userId) {
        return this.prisma.verificationRequest.findMany({ where: { userId } });
    }
    async getExpiringVerifications(days = 30) {
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() + days);
        return this.prisma.verificationRequest.findMany({
            where: {
                status: client_1.VerificationRequestStatus.APPROVED,
                expiresAt: { lt: cutoffDate },
            },
        });
    }
    async renewVerification(id) {
        const request = await this.prisma.verificationRequest.findUnique({ where: { id } });
        if (!request || request.status !== client_1.VerificationRequestStatus.APPROVED || !request.expiresAt) {
            return null;
        }
        return this.prisma.verificationRequest.update({
            where: { id },
            data: {
                expiresAt: new Date(new Date(request.expiresAt).setFullYear(new Date().getFullYear() + 1)),
            },
        });
    }
    async getVerificationStats() {
        const total = await this.prisma.verificationRequest.count();
        const pending = await this.prisma.verificationRequest.count({ where: { status: client_1.VerificationRequestStatus.PENDING } });
        const approved = await this.prisma.verificationRequest.count({ where: { status: client_1.VerificationRequestStatus.APPROVED } });
        const rejected = await this.prisma.verificationRequest.count({ where: { status: client_1.VerificationRequestStatus.REJECTED } });
        const expiringSoonRequests = await this.getExpiringVerifications(30);
        const expiringSoon = expiringSoonRequests.length;
        return {
            total,
            pending,
            approved,
            rejected,
            expiringSoon,
        };
    }
};
exports.VerificationService = VerificationService;
exports.VerificationService = VerificationService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], VerificationService);
//# sourceMappingURL=verification.service.js.map