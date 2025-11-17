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
Object.defineProperty(exports, "__esModule", { value: true });
exports.StorageService = void 0;
const common_1 = require("@nestjs/common");
const storage_1 = require("@google-cloud/storage");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
const path = __importStar(require("path"));
let StorageService = class StorageService {
    prisma;
    storageEnabled;
    storage;
    bucketPrefix;
    defaultTtlMs;
    constructor(prisma) {
        this.prisma = prisma;
        this.storageEnabled = process.env.GCS_SIGNED_URLS !== 'disabled';
        this.bucketPrefix = process.env.MEDIA_BUCKET_PREFIX ?? 'mesteri-media';
        this.defaultTtlMs = Number(process.env.SIGNED_URL_TTL_MS ?? 15 * 60 * 1000);
        this.storage = this.storageEnabled ? new storage_1.Storage() : null;
    }
    async createUploadUrl(userId, dto) {
        if (!this.storage || !this.storageEnabled) {
            throw new common_1.ServiceUnavailableException('Signed URL service is not configured.');
        }
        const bucketName = this.resolveBucketName(dto.bucketHint);
        const objectPath = this.buildObjectPath(dto, userId);
        const expires = Date.now() + this.defaultTtlMs;
        const bucket = this.storage.bucket(bucketName);
        const file = bucket.file(objectPath);
        const config = {
            action: 'write',
            expires,
            contentType: dto.contentType,
        };
        try {
            const [uploadUrl] = await file.getSignedUrl(config);
            const retentionPolicyCode = dto.entityType === client_1.AttachmentEntity.CONTRACT
                ? 'STANDARD_GUARANTEE'
                : 'SUPPORT_THREAD';
            const retentionPolicy = await this.prisma.retentionPolicy.findUnique({
                where: { code: retentionPolicyCode },
            });
            if (!retentionPolicy) {
                throw new common_1.InternalServerErrorException('Retention policy not found');
            }
            const attachment = await this.prisma.attachment.create({
                data: {
                    bucket: bucketName,
                    objectPath,
                    contentType: dto.contentType,
                    fileSize: 0,
                    checksumSha256: 'pending',
                    uploadedById: userId,
                    retentionPolicyId: retentionPolicy.id,
                    status: client_1.AttachmentStatus.PENDING,
                },
            });
            return {
                attachmentId: attachment.id,
                uploadUrl,
                bucket: bucketName,
                objectPath,
                expiresAt: new Date(expires).toISOString(),
            };
        }
        catch (error) {
            throw new common_1.InternalServerErrorException('Unable to generate upload URL');
        }
    }
    resolveBucketName(hint) {
        if (hint) {
            return hint;
        }
        const env = process.env.APPLICATION_ENV ?? process.env.NODE_ENV ?? 'dev';
        return `${this.bucketPrefix}-${env}`;
    }
    buildObjectPath(dto, userId) {
        const now = new Date();
        const ext = path.extname(dto.fileName) || this.extensionFromMime(dto.contentType);
        const safeBase = dto.fileName.replace(/[^\w\-. ]/g, '');
        const segment = (dto.entityType ?? client_1.AttachmentEntity.MESSAGE).toLowerCase();
        const timestamp = now.toISOString().replace(/[:.]/g, '-');
        return `${segment}/${userId}/${timestamp}-${safeBase}${ext}`;
    }
    extensionFromMime(mime) {
        if (mime.includes('jpeg'))
            return '.jpg';
        if (mime.includes('png'))
            return '.png';
        if (mime.includes('pdf'))
            return '.pdf';
        return '';
    }
};
exports.StorageService = StorageService;
exports.StorageService = StorageService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], StorageService);
//# sourceMappingURL=storage.service.js.map