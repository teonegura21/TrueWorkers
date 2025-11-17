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
exports.VerificationController = void 0;
const common_1 = require("@nestjs/common");
const verification_service_1 = require("./verification.service");
const firebase_auth_guard_1 = require("../guards/firebase-auth.guard");
const create_verification_request_dto_1 = require("./dto/create-verification-request.dto");
const update_verification_request_dto_1 = require("./dto/update-verification-request.dto");
const create_document_dto_1 = require("./dto/create-document.dto");
let VerificationController = class VerificationController {
    verificationService;
    constructor(verificationService) {
        this.verificationService = verificationService;
    }
    findAll() {
        return this.verificationService.findAll();
    }
    findOne(id) {
        return this.verificationService.findOne(id);
    }
    findByUserId(userId) {
        return this.verificationService.findByUserId(userId);
    }
    findByType(type) {
        return this.verificationService.findByType(type);
    }
    findByStatus(status) {
        return this.verificationService.findByStatus(status);
    }
    create(verificationData) {
        return this.verificationService.create(verificationData);
    }
    update(id, updateData) {
        return this.verificationService.update(id, updateData);
    }
    delete(id) {
        return this.verificationService.delete(id);
    }
    submitForReview(id) {
        return this.verificationService.submitForReview(id);
    }
    approveRequest(id, reviewerId, notes) {
        return this.verificationService.approveRequest(id, reviewerId.toString(), notes);
    }
    rejectRequest(id, reviewerId, reason) {
        return this.verificationService.rejectRequest(id, reviewerId.toString(), reason);
    }
    addDocument(requestId, documentData) {
        return this.verificationService.addDocument(requestId, documentData);
    }
    verifyDocument(documentId) {
        return this.verificationService.verifyDocument(documentId);
    }
    rejectDocument(documentId, reason) {
        return this.verificationService.rejectDocument(documentId, reason);
    }
    getUserBadges(userId) {
        return this.verificationService.getUserBadges(userId);
    }
    getAllBadges() {
        return this.verificationService.getAllBadges();
    }
    getBadgeById(id) {
        return this.verificationService.getBadgeById(id);
    }
    getUserVerificationStatus(userId) {
        return this.verificationService.getUserVerificationStatus(userId);
    }
    getPendingVerifications() {
        return this.verificationService.getPendingVerifications();
    }
    getApprovedVerifications() {
        return this.verificationService.getApprovedVerifications();
    }
    getRejectedVerifications() {
        return this.verificationService.getRejectedVerifications();
    }
    getUserVerificationRequests(userId) {
        return this.verificationService.getUserVerificationRequests(userId);
    }
    getExpiringVerifications(days) {
        return this.verificationService.getExpiringVerifications(days ? parseInt(days) : 30);
    }
    renewVerification(id) {
        return this.verificationService.renewVerification(id);
    }
    getVerificationStats() {
        return this.verificationService.getVerificationStats();
    }
};
exports.VerificationController = VerificationController;
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "findOne", null);
__decorate([
    (0, common_1.Get)('user/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "findByUserId", null);
__decorate([
    (0, common_1.Get)('type/:type'),
    __param(0, (0, common_1.Param)('type')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "findByType", null);
__decorate([
    (0, common_1.Get)('status/:status'),
    __param(0, (0, common_1.Param)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "findByStatus", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_verification_request_dto_1.CreateVerificationRequestDto]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_verification_request_dto_1.UpdateVerificationRequestDto]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "delete", null);
__decorate([
    (0, common_1.Post)(':id/submit'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "submitForReview", null);
__decorate([
    (0, common_1.Post)(':id/approve'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reviewerId')),
    __param(2, (0, common_1.Body)('notes')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Number, String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "approveRequest", null);
__decorate([
    (0, common_1.Post)(':id/reject'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reviewerId')),
    __param(2, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Number, String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "rejectRequest", null);
__decorate([
    (0, common_1.Post)(':requestId/documents'),
    __param(0, (0, common_1.Param)('requestId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, create_document_dto_1.CreateDocumentDto]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "addDocument", null);
__decorate([
    (0, common_1.Post)('documents/:documentId/verify'),
    __param(0, (0, common_1.Param)('documentId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "verifyDocument", null);
__decorate([
    (0, common_1.Post)('documents/:documentId/reject'),
    __param(0, (0, common_1.Param)('documentId')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "rejectDocument", null);
__decorate([
    (0, common_1.Get)('badges/user/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "getUserBadges", null);
__decorate([
    (0, common_1.Get)('badges'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "getAllBadges", null);
__decorate([
    (0, common_1.Get)('badges/:id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "getBadgeById", null);
__decorate([
    (0, common_1.Get)('status/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "getUserVerificationStatus", null);
__decorate([
    (0, common_1.Get)('pending'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "getPendingVerifications", null);
__decorate([
    (0, common_1.Get)('approved'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "getApprovedVerifications", null);
__decorate([
    (0, common_1.Get)('rejected'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "getRejectedVerifications", null);
__decorate([
    (0, common_1.Get)('user/:userId/requests'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "getUserVerificationRequests", null);
__decorate([
    (0, common_1.Get)('expiring'),
    __param(0, (0, common_1.Query)('days')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "getExpiringVerifications", null);
__decorate([
    (0, common_1.Post)(':id/renew'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "renewVerification", null);
__decorate([
    (0, common_1.Get)('stats'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], VerificationController.prototype, "getVerificationStats", null);
exports.VerificationController = VerificationController = __decorate([
    (0, common_1.Controller)('verification'),
    (0, common_1.UseGuards)(firebase_auth_guard_1.FirebaseAuthGuard),
    __metadata("design:paramtypes", [verification_service_1.VerificationService])
], VerificationController);
//# sourceMappingURL=verification.controller.js.map