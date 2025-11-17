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
exports.InspirationController = void 0;
const common_1 = require("@nestjs/common");
const inspiration_service_1 = require("./inspiration.service");
const firebase_auth_guard_1 = require("../guards/firebase-auth.guard");
let InspirationController = class InspirationController {
    inspirationService;
    constructor(inspirationService) {
        this.inspirationService = inspirationService;
    }
    async getFeed(page, limit, userId) {
        const pageNum = page ? parseInt(page, 10) : 1;
        const limitNum = limit ? parseInt(limit, 10) : 20;
        return this.inspirationService.getFeed(userId, pageNum, limitNum);
    }
    async findAll(craftsmanId, city, skill, isPromoted, page, limit) {
        const filters = {
            craftsmanId,
            city,
            skill,
            isPromoted: isPromoted === 'true' ? true : undefined,
            page: page ? parseInt(page, 10) : 1,
            limit: limit ? parseInt(limit, 10) : 20,
        };
        return this.inspirationService.findAll(filters);
    }
    async findOne(id) {
        return this.inspirationService.findOne(id);
    }
    async create(createDto) {
        return this.inspirationService.create(createDto);
    }
    async update(id, updateDto) {
        return this.inspirationService.update(id, updateDto);
    }
    async delete(id) {
        return this.inspirationService.delete(id);
    }
    async like(id) {
        return this.inspirationService.incrementLikes(id);
    }
    async share(id) {
        return this.inspirationService.incrementShares(id);
    }
};
exports.InspirationController = InspirationController;
__decorate([
    (0, common_1.Get)('feed'),
    __param(0, (0, common_1.Query)('page')),
    __param(1, (0, common_1.Query)('limit')),
    __param(2, (0, common_1.Query)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", Promise)
], InspirationController.prototype, "getFeed", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('craftsmanId')),
    __param(1, (0, common_1.Query)('city')),
    __param(2, (0, common_1.Query)('skill')),
    __param(3, (0, common_1.Query)('isPromoted')),
    __param(4, (0, common_1.Query)('page')),
    __param(5, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String, String, String]),
    __metadata("design:returntype", Promise)
], InspirationController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], InspirationController.prototype, "findOne", null);
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UseGuards)(firebase_auth_guard_1.FirebaseAuthGuard),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], InspirationController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    (0, common_1.UseGuards)(firebase_auth_guard_1.FirebaseAuthGuard),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], InspirationController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.UseGuards)(firebase_auth_guard_1.FirebaseAuthGuard),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], InspirationController.prototype, "delete", null);
__decorate([
    (0, common_1.Post)(':id/like'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], InspirationController.prototype, "like", null);
__decorate([
    (0, common_1.Post)(':id/share'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], InspirationController.prototype, "share", null);
exports.InspirationController = InspirationController = __decorate([
    (0, common_1.Controller)('inspiration'),
    __metadata("design:paramtypes", [inspiration_service_1.InspirationService])
], InspirationController);
//# sourceMappingURL=inspiration.controller.js.map