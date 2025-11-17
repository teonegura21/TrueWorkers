import { PrismaService } from '../prisma/prisma.service';
import { MediaCategory } from './dto';
export declare enum MediaFileType {
    IMAGE = "IMAGE",
    VIDEO = "VIDEO"
}
export declare enum MediaStatus {
    PROCESSING = "PROCESSING",
    ACTIVE = "ACTIVE",
    FAILED = "FAILED",
    DELETED = "DELETED"
}
export declare class MediaUploadService {
    private readonly prisma;
    private readonly logger;
    private readonly uploadPath;
    private readonly imageQuality;
    private readonly thumbnailSize;
    private readonly mediumSize;
    private readonly maxVideoDuration;
    constructor(prisma: PrismaService);
    uploadImage(file: Express.Multer.File, userId: string, category: MediaCategory, entityId?: string): Promise<{
        id: string;
        url: string;
        thumbnailUrl: string;
        mediumUrl: string;
        width: number;
        height: number;
        fileSize: number;
        mimeType: string;
    }>;
    uploadVideo(file: Express.Multer.File, userId: string, category: MediaCategory, entityId?: string): Promise<{
        id: string;
        url: string;
        thumbnailUrl: string;
        duration: number;
        width: number;
        height: number;
        fileSize: number;
        mimeType: string;
    }>;
    uploadMultiple(files: Express.Multer.File[], userId: string, category: MediaCategory, entityId?: string): Promise<{
        files: any[];
        totalUploaded: number;
        failed: any[];
    }>;
    deleteFile(id: string, userId: string): Promise<{
        message: string;
        id: string;
    }>;
    getUserMedia(userId: string, category: MediaCategory, page?: number, limit?: number, sortBy?: string, order?: 'asc' | 'desc'): Promise<{
        media: {
            id: string;
            status: import("@prisma/client").$Enums.AttachmentStatus;
            retentionPolicyId: string;
            bucket: string;
            objectPath: string;
            contentType: string;
            fileSize: number;
            checksumSha256: string;
            uploadedAt: Date;
            uploadedById: string;
        }[];
        total: number;
        page: number;
        totalPages: number;
    }>;
    private processImage;
    private processVideo;
    private getVideoMetadata;
    private compressVideo;
    private extractVideoThumbnail;
    private generateFilename;
}
