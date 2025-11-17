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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var MediaUploadService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.MediaUploadService = exports.MediaStatus = exports.MediaFileType = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const sharp_1 = __importDefault(require("sharp"));
const fluent_ffmpeg_1 = __importDefault(require("fluent-ffmpeg"));
const ffmpeg_static_1 = __importDefault(require("ffmpeg-static"));
const uuid_1 = require("uuid");
const fs = __importStar(require("fs/promises"));
const path = __importStar(require("path"));
if (ffmpeg_static_1.default && typeof ffmpeg_static_1.default === 'string') {
    fluent_ffmpeg_1.default.setFfmpegPath(ffmpeg_static_1.default);
}
var MediaFileType;
(function (MediaFileType) {
    MediaFileType["IMAGE"] = "IMAGE";
    MediaFileType["VIDEO"] = "VIDEO";
})(MediaFileType || (exports.MediaFileType = MediaFileType = {}));
var MediaStatus;
(function (MediaStatus) {
    MediaStatus["PROCESSING"] = "PROCESSING";
    MediaStatus["ACTIVE"] = "ACTIVE";
    MediaStatus["FAILED"] = "FAILED";
    MediaStatus["DELETED"] = "DELETED";
})(MediaStatus || (exports.MediaStatus = MediaStatus = {}));
let MediaUploadService = MediaUploadService_1 = class MediaUploadService {
    prisma;
    logger = new common_1.Logger(MediaUploadService_1.name);
    uploadPath = process.env.UPLOAD_PATH || './storage/uploads';
    imageQuality = parseInt(process.env.IMAGE_QUALITY || '85');
    thumbnailSize = parseInt(process.env.THUMBNAIL_SIZE || '300');
    mediumSize = parseInt(process.env.MEDIUM_SIZE || '800');
    maxVideoDuration = parseInt(process.env.MAX_VIDEO_DURATION || '300');
    constructor(prisma) {
        this.prisma = prisma;
    }
    async uploadImage(file, userId, category, entityId) {
        try {
            const processed = await this.processImage(file, userId, category);
            if (processed.width < 400 || processed.height < 400) {
                throw new common_1.BadRequestException('Image dimensions must be at least 400x400 pixels.');
            }
            if (processed.width > 4000 || processed.height > 4000) {
                throw new common_1.BadRequestException('Image dimensions must not exceed 4000x4000 pixels.');
            }
            const attachment = await this.prisma.attachment.create({
                data: {
                    bucket: 'mesteri-media',
                    objectPath: processed.originalUrl.replace('./storage/uploads/', ''),
                    contentType: file.mimetype,
                    fileSize: processed.fileSize,
                    checksumSha256: '',
                    uploadedById: userId,
                    retentionPolicyId: 'default-policy',
                    status: 'ACTIVE',
                },
            });
            await this.prisma.attachmentLink.create({
                data: {
                    attachmentId: attachment.id,
                    entityType: 'MESSAGE',
                    entityId: entityId || 'unknown',
                    role: 'media',
                },
            });
            const mediaAttachment = {
                id: attachment.id,
                fileUrl: `./storage/uploads/${attachment.objectPath}`,
                thumbnailUrl: processed.thumbnailUrl,
                mediumUrl: processed.mediumUrl,
                fileType: MediaFileType.IMAGE,
                category,
                entityId,
                fileName: file.originalname,
                mimeType: file.mimetype,
                fileSize: processed.fileSize,
                width: processed.width,
                height: processed.height,
                status: MediaStatus.ACTIVE,
                createdAt: attachment.uploadedAt,
                updatedAt: attachment.uploadedAt,
            };
            return {
                id: mediaAttachment.id,
                url: processed.originalUrl,
                thumbnailUrl: processed.thumbnailUrl,
                mediumUrl: processed.mediumUrl,
                width: processed.width,
                height: processed.height,
                fileSize: processed.fileSize,
                mimeType: file.mimetype,
            };
        }
        catch (error) {
            this.logger.error('Image upload failed', error);
            throw error;
        }
    }
    async uploadVideo(file, userId, category, entityId) {
        try {
            const processed = await this.processVideo(file, userId, category);
            if (processed.duration > this.maxVideoDuration) {
                throw new common_1.BadRequestException(`Video duration must not exceed ${this.maxVideoDuration} seconds.`);
            }
            const attachment = await this.prisma.attachment.create({
                data: {
                    bucket: 'mesteri-media',
                    objectPath: processed.url.replace('./storage/uploads/', ''),
                    contentType: 'video/mp4',
                    fileSize: processed.fileSize,
                    checksumSha256: '',
                    uploadedById: userId,
                    retentionPolicyId: 'default-policy',
                    status: 'ACTIVE',
                },
            });
            await this.prisma.attachmentLink.create({
                data: {
                    attachmentId: attachment.id,
                    entityType: 'MESSAGE',
                    entityId: entityId || 'unknown',
                    role: 'media',
                },
            });
            const mediaAttachment = {
                id: attachment.id,
                url: `./storage/uploads/${attachment.objectPath}`,
                thumbnailUrl: processed.thumbnailUrl,
                duration: processed.duration,
                width: processed.width,
                height: processed.height,
                fileSize: processed.fileSize,
                mimeType: 'video/mp4',
            };
            return {
                id: mediaAttachment.id,
                url: processed.url,
                thumbnailUrl: processed.thumbnailUrl,
                duration: processed.duration,
                width: processed.width,
                height: processed.height,
                fileSize: processed.fileSize,
                mimeType: 'video/mp4',
            };
        }
        catch (error) {
            this.logger.error('Video upload failed', error);
            throw error;
        }
    }
    async uploadMultiple(files, userId, category, entityId) {
        const results = [];
        const failed = [];
        for (const file of files) {
            try {
                const isImage = file.mimetype.startsWith('image/');
                const result = isImage
                    ? await this.uploadImage(file, userId, category, entityId)
                    : await this.uploadVideo(file, userId, category, entityId);
                results.push(result);
            }
            catch (error) {
                failed.push({
                    fileName: file.originalname,
                    error: error.message,
                });
            }
        }
        return {
            files: results,
            totalUploaded: results.length,
            failed,
        };
    }
    async deleteFile(id, userId) {
        const media = await this.prisma.attachment.findUnique({
            where: { id },
        });
        if (!media) {
            throw new common_1.BadRequestException('Media not found');
        }
        if (media.uploadedById !== userId) {
            throw new common_1.BadRequestException('Not authorized to delete this media');
        }
        try {
            const basePath = path.join(process.cwd(), this.uploadPath);
            await fs.unlink(path.join(basePath, media.objectPath));
            const thumbnailPath = media.objectPath.replace('.', '-thumb.');
            const mediumPath = media.objectPath.replace('.', '-medium.');
            try {
                await fs.unlink(path.join(basePath, thumbnailPath));
            }
            catch (e) {
            }
            try {
                await fs.unlink(path.join(basePath, mediumPath));
            }
            catch (e) {
            }
        }
        catch (error) {
            this.logger.error('Failed to delete physical files', error);
        }
        await this.prisma.attachment.update({
            where: { id },
            data: { status: MediaStatus.DELETED },
        });
        return { message: 'Media deleted successfully', id };
    }
    async getUserMedia(userId, category, page = 1, limit = 20, sortBy = 'createdAt', order = 'desc') {
        const skip = (page - 1) * limit;
        const [media, total] = await Promise.all([
            this.prisma.attachment.findMany({
                where: {
                    uploadedById: userId,
                    status: 'ACTIVE',
                },
                skip,
                take: limit,
                orderBy: { [sortBy]: order },
            }),
            this.prisma.attachment.count({
                where: {
                    uploadedById: userId,
                    status: 'ACTIVE',
                },
            }),
        ]);
        return {
            media,
            total,
            page,
            totalPages: Math.ceil(total / limit),
        };
    }
    async processImage(file, userId, category) {
        const filename = this.generateFilename(file.originalname);
        const categoryPath = category.toLowerCase();
        const dir = path.join(process.cwd(), this.uploadPath, 'images', categoryPath, userId);
        await fs.mkdir(dir, { recursive: true });
        const originalPath = path.join(dir, `${filename}-original.jpg`);
        const thumbnailPath = path.join(dir, `${filename}-thumb.jpg`);
        const mediumPath = path.join(dir, `${filename}-medium.jpg`);
        const image = (0, sharp_1.default)(file.buffer);
        const metadata = await image.metadata();
        await image
            .jpeg({ quality: this.imageQuality })
            .toFile(originalPath);
        await (0, sharp_1.default)(file.buffer)
            .resize(this.thumbnailSize, this.thumbnailSize, { fit: 'cover' })
            .jpeg({ quality: 80 })
            .toFile(thumbnailPath);
        await (0, sharp_1.default)(file.buffer)
            .resize(this.mediumSize, this.mediumSize, { fit: 'inside' })
            .jpeg({ quality: 85 })
            .toFile(mediumPath);
        const stats = await fs.stat(originalPath);
        return {
            originalUrl: `/images/${categoryPath}/${userId}/${filename}-original.jpg`,
            thumbnailUrl: `/images/${categoryPath}/${userId}/${filename}-thumb.jpg`,
            mediumUrl: `/images/${categoryPath}/${userId}/${filename}-medium.jpg`,
            width: metadata.width || 0,
            height: metadata.height || 0,
            fileSize: stats.size,
        };
    }
    async processVideo(file, userId, category) {
        const filename = this.generateFilename(file.originalname);
        const categoryPath = category.toLowerCase();
        const dir = path.join(process.cwd(), this.uploadPath, 'videos', categoryPath, userId);
        await fs.mkdir(dir, { recursive: true });
        const tempPath = path.join(dir, `temp-${filename}.mp4`);
        await fs.writeFile(tempPath, file.buffer);
        const outputPath = path.join(dir, `${filename}.mp4`);
        const thumbnailPath = path.join(dir, `${filename}-thumb.jpg`);
        try {
            const metadata = await this.getVideoMetadata(tempPath);
            await this.compressVideo(tempPath, outputPath);
            await this.extractVideoThumbnail(outputPath, thumbnailPath);
            await fs.unlink(tempPath);
            const stats = await fs.stat(outputPath);
            return {
                url: `/videos/${categoryPath}/${userId}/${filename}.mp4`,
                thumbnailUrl: `/videos/${categoryPath}/${userId}/${filename}-thumb.jpg`,
                width: metadata.width || 1280,
                height: metadata.height || 720,
                duration: metadata.duration || 0,
                fileSize: stats.size,
            };
        }
        catch (error) {
            try {
                await fs.unlink(tempPath);
            }
            catch { }
            throw new common_1.InternalServerErrorException('Video processing failed');
        }
    }
    async getVideoMetadata(filePath) {
        return new Promise((resolve, reject) => {
            fluent_ffmpeg_1.default.ffprobe(filePath, (err, metadata) => {
                if (err) {
                    reject(err);
                    return;
                }
                const videoStream = metadata.streams.find((s) => s.codec_type === 'video');
                resolve({
                    width: videoStream?.width,
                    height: videoStream?.height,
                    duration: metadata.format.duration,
                });
            });
        });
    }
    async compressVideo(inputPath, outputPath) {
        return new Promise((resolve, reject) => {
            (0, fluent_ffmpeg_1.default)(inputPath)
                .outputOptions([
                '-c:v libx264',
                '-preset medium',
                '-crf 23',
                '-vf scale=1280:720:force_original_aspect_ratio=decrease',
                '-c:a aac',
                '-b:a 128k',
                '-movflags +faststart',
            ])
                .output(outputPath)
                .on('end', () => resolve())
                .on('error', (err) => reject(err))
                .run();
        });
    }
    async extractVideoThumbnail(videoPath, thumbnailPath) {
        return new Promise((resolve, reject) => {
            (0, fluent_ffmpeg_1.default)(videoPath)
                .screenshots({
                timestamps: ['1'],
                filename: path.basename(thumbnailPath),
                folder: path.dirname(thumbnailPath),
                size: '300x300',
            })
                .on('end', () => resolve())
                .on('error', (err) => reject(err));
        });
    }
    generateFilename(originalName) {
        const uuid = (0, uuid_1.v4)();
        const timestamp = new Date()
            .toISOString()
            .replace(/[:.]/g, '-')
            .substring(0, 19);
        return `${uuid}-${timestamp}`;
    }
};
exports.MediaUploadService = MediaUploadService;
exports.MediaUploadService = MediaUploadService = MediaUploadService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], MediaUploadService);
//# sourceMappingURL=media-upload.service.js.map