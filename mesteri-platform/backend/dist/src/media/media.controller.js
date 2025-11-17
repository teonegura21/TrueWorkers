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
exports.MediaController = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const media_upload_service_1 = require("./media-upload.service");
const dto_1 = require("./dto");
const firebase_auth_guard_1 = require("../guards/firebase-auth.guard");
let MediaController = class MediaController {
    mediaUploadService;
    constructor(mediaUploadService) {
        this.mediaUploadService = mediaUploadService;
    }
    async uploadImage(file, dto, req) {
        if (!file) {
            throw new common_1.BadRequestException('No file provided');
        }
        const userId = req.user.uid;
        return this.mediaUploadService.uploadImage(file, userId, dto.category, dto.entityId);
    }
    async uploadVideo(file, dto, req) {
        if (!file) {
            throw new common_1.BadRequestException('No file provided');
        }
        const userId = req.user.uid;
        return this.mediaUploadService.uploadVideo(file, userId, dto.category, dto.entityId);
    }
    async uploadBatch(files, dto, req) {
        if (!files || files.length === 0) {
            throw new common_1.BadRequestException('No files provided');
        }
        const userId = req.user.uid;
        const result = await this.mediaUploadService.uploadMultiple(files, userId, dto.category, dto.entityId);
        if (result.failed.length > 0) {
            return {
                statusCode: 207,
                ...result,
            };
        }
        return result;
    }
    async deleteMedia(id, req) {
        const userId = req.user.uid;
        return this.mediaUploadService.deleteFile(id, userId);
    }
    async getUserMedia(userId, category, query) {
        if (!Object.values(dto_1.MediaCategory).includes(category)) {
            throw new common_1.BadRequestException('Invalid category');
        }
        return this.mediaUploadService.getUserMedia(userId, category, query.page, query.limit, query.sortBy, query.order);
    }
};
exports.MediaController = MediaController;
__decorate([
    (0, common_1.Post)('upload/image'),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('file')),
    __param(0, (0, common_1.UploadedFile)()),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, dto_1.UploadMediaDto, Object]),
    __metadata("design:returntype", Promise)
], MediaController.prototype, "uploadImage", null);
__decorate([
    (0, common_1.Post)('upload/video'),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('file')),
    __param(0, (0, common_1.UploadedFile)()),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, dto_1.UploadMediaDto, Object]),
    __metadata("design:returntype", Promise)
], MediaController.prototype, "uploadVideo", null);
__decorate([
    (0, common_1.Post)('upload/batch'),
    (0, common_1.UseInterceptors)((0, platform_express_1.FilesInterceptor)('files', 10)),
    __param(0, (0, common_1.UploadedFiles)()),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Array, dto_1.UploadMediaDto, Object]),
    __metadata("design:returntype", Promise)
], MediaController.prototype, "uploadBatch", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], MediaController.prototype, "deleteMedia", null);
__decorate([
    (0, common_1.Get)(':userId/:category'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Param)('category')),
    __param(2, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, dto_1.GetMediaQueryDto]),
    __metadata("design:returntype", Promise)
], MediaController.prototype, "getUserMedia", null);
exports.MediaController = MediaController = __decorate([
    (0, common_1.Controller)('media'),
    (0, common_1.UseGuards)(firebase_auth_guard_1.FirebaseAuthGuard),
    __metadata("design:paramtypes", [media_upload_service_1.MediaUploadService])
], MediaController);
//# sourceMappingURL=media.controller.js.map