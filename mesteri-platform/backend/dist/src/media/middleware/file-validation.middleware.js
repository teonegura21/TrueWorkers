"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FileValidationMiddleware = void 0;
const common_1 = require("@nestjs/common");
let FileValidationMiddleware = class FileValidationMiddleware {
    MAX_IMAGE_SIZE = parseInt(process.env.MAX_IMAGE_SIZE || '10485760');
    MAX_VIDEO_SIZE = parseInt(process.env.MAX_VIDEO_SIZE || '104857600');
    MAX_BATCH_FILES = parseInt(process.env.MAX_BATCH_FILES || '10');
    ALLOWED_IMAGE_MIMES = [
        'image/jpeg',
        'image/png',
        'image/webp',
    ];
    ALLOWED_VIDEO_MIMES = [
        'video/mp4',
        'video/quicktime',
        'video/x-msvideo',
    ];
    IMAGE_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.webp'];
    VIDEO_EXTENSIONS = ['.mp4', '.mov', '.avi'];
    use(req, res, next) {
        const files = req.files;
        const file = req.file;
        if (!files && !file) {
            return next();
        }
        try {
            if (files && Array.isArray(files)) {
                this.validateBatchFiles(files);
            }
            else if (file) {
                this.validateSingleFile(file);
            }
            next();
        }
        catch (error) {
            next(error);
        }
    }
    validateSingleFile(file) {
        const errors = [];
        if (!this.ALLOWED_IMAGE_MIMES.includes(file.mimetype) &&
            !this.ALLOWED_VIDEO_MIMES.includes(file.mimetype)) {
            errors.push('Unsupported file type. Please use JPG, PNG, WEBP for images or MP4, MOV, AVI for videos.');
        }
        const isImage = this.ALLOWED_IMAGE_MIMES.includes(file.mimetype);
        const isVideo = this.ALLOWED_VIDEO_MIMES.includes(file.mimetype);
        const maxSize = isImage ? this.MAX_IMAGE_SIZE : this.MAX_VIDEO_SIZE;
        if (file.size > maxSize) {
            const maxSizeMB = maxSize / 1024 / 1024;
            errors.push(`File size exceeds maximum of ${maxSizeMB}MB for ${isImage ? 'images' : 'videos'}.`);
        }
        const fileExt = file.originalname
            .substring(file.originalname.lastIndexOf('.'))
            .toLowerCase();
        const allowedExtensions = isImage
            ? this.IMAGE_EXTENSIONS
            : this.VIDEO_EXTENSIONS;
        if (!allowedExtensions.includes(fileExt)) {
            errors.push(`Invalid file extension. Allowed: ${allowedExtensions.join(', ')}`);
        }
        if (errors.length > 0) {
            throw new common_1.BadRequestException({
                statusCode: 400,
                message: 'File validation failed',
                errors,
            });
        }
    }
    validateBatchFiles(files) {
        if (files.length > this.MAX_BATCH_FILES) {
            throw new common_1.BadRequestException(`Maximum ${this.MAX_BATCH_FILES} files allowed per batch upload.`);
        }
        const errors = [];
        files.forEach((file, index) => {
            try {
                this.validateSingleFile(file);
            }
            catch (error) {
                if (error.response?.errors) {
                    errors.push(`File ${index + 1} (${file.originalname}): ${error.response.errors.join(', ')}`);
                }
            }
        });
        if (errors.length > 0) {
            throw new common_1.BadRequestException({
                statusCode: 400,
                message: 'Batch file validation failed',
                errors,
            });
        }
    }
};
exports.FileValidationMiddleware = FileValidationMiddleware;
exports.FileValidationMiddleware = FileValidationMiddleware = __decorate([
    (0, common_1.Injectable)()
], FileValidationMiddleware);
//# sourceMappingURL=file-validation.middleware.js.map