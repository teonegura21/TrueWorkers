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
exports.ReviewsController = void 0;
const common_1 = require("@nestjs/common");
const reviews_service_1 = require("./reviews.service");
const firebase_auth_guard_1 = require("../guards/firebase-auth.guard");
let ReviewsController = class ReviewsController {
    reviewsService;
    constructor(reviewsService) {
        this.reviewsService = reviewsService;
    }
    async findAll() {
        return await this.reviewsService.findAllReviews();
    }
    async findOne(id) {
        return await this.reviewsService.findReviewById(id);
    }
    async findByUserId(userId) {
        return await this.reviewsService.findReviewsByUserId(userId);
    }
    findByReviewerId(userId) {
        return this.reviewsService.findReviewsByReviewerId(userId);
    }
    findByProjectId(projectId) {
        return this.reviewsService.findReviewsByProjectId(projectId);
    }
    findByRating(rating) {
        return this.reviewsService.findReviewsByRating(parseInt(rating));
    }
    findByTag(tag) {
        return this.reviewsService.findReviewsByTag(tag);
    }
    update(id, updateData) {
        return this.reviewsService.updateReview(id, updateData);
    }
    delete(id) {
        return this.reviewsService.deleteReview(id);
    }
    approveReview(id) {
        return this.reviewsService.approveReview(id);
    }
    rejectReview(id, reason) {
        return this.reviewsService.rejectReview(id, reason);
    }
    reportReview(id, reason) {
        return this.reviewsService.reportReview(id, reason);
    }
    markAsHelpful(id, isHelpful) {
        return this.reviewsService.markAsHelpful(id, isHelpful);
    }
    getReviewStats(userId) {
        return this.reviewsService.getReviewStats(userId);
    }
    getTopRatedUsers(minReviews, minRating) {
        return this.reviewsService.getTopRatedUsers(minReviews ? parseInt(minReviews) : 5, minRating ? parseFloat(minRating) : 4.5);
    }
    getRecentReviews(limit) {
        return this.reviewsService.getRecentReviews(limit ? parseInt(limit) : 10);
    }
    searchReviews(query) {
        return this.reviewsService.searchReviews(query);
    }
    getTrendingReviews(days) {
        return this.reviewsService.getTrendingReviews(days ? parseInt(days) : 7);
    }
};
exports.ReviewsController = ReviewsController;
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Get)('user/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ReviewsController.prototype, "findByUserId", null);
__decorate([
    (0, common_1.Get)('reviewer/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "findByReviewerId", null);
__decorate([
    (0, common_1.Get)('project/:projectId'),
    __param(0, (0, common_1.Param)('projectId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "findByProjectId", null);
__decorate([
    (0, common_1.Get)('rating/:rating'),
    __param(0, (0, common_1.Param)('rating')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "findByRating", null);
__decorate([
    (0, common_1.Get)('tag/:tag'),
    __param(0, (0, common_1.Param)('tag')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "findByTag", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "delete", null);
__decorate([
    (0, common_1.Post)(':id/approve'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "approveReview", null);
__decorate([
    (0, common_1.Post)(':id/reject'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "rejectReview", null);
__decorate([
    (0, common_1.Post)(':id/report'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('reason')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "reportReview", null);
__decorate([
    (0, common_1.Post)(':id/helpful'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('isHelpful')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Boolean]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "markAsHelpful", null);
__decorate([
    (0, common_1.Get)('stats'),
    __param(0, (0, common_1.Query)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "getReviewStats", null);
__decorate([
    (0, common_1.Get)('top-rated'),
    __param(0, (0, common_1.Query)('minReviews')),
    __param(1, (0, common_1.Query)('minRating')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "getTopRatedUsers", null);
__decorate([
    (0, common_1.Get)('recent'),
    __param(0, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "getRecentReviews", null);
__decorate([
    (0, common_1.Get)('search'),
    __param(0, (0, common_1.Query)('q')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "searchReviews", null);
__decorate([
    (0, common_1.Get)('trending'),
    __param(0, (0, common_1.Query)('days')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ReviewsController.prototype, "getTrendingReviews", null);
exports.ReviewsController = ReviewsController = __decorate([
    (0, common_1.Controller)('reviews'),
    (0, common_1.UseGuards)(firebase_auth_guard_1.FirebaseAuthGuard),
    __metadata("design:paramtypes", [reviews_service_1.ReviewsService])
], ReviewsController);
//# sourceMappingURL=reviews.controller.js.map