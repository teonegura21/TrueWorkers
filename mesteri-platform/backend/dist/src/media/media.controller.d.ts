import { MediaUploadService } from './media-upload.service';
import { UploadMediaDto, GetMediaQueryDto } from './dto';
export declare class MediaController {
    private readonly mediaUploadService;
    constructor(mediaUploadService: MediaUploadService);
    uploadImage(file: Express.Multer.File, dto: UploadMediaDto, req: any): Promise<{
        id: string;
        url: string;
        thumbnailUrl: string;
        mediumUrl: string;
        width: number;
        height: number;
        fileSize: number;
        mimeType: string;
    }>;
    uploadVideo(file: Express.Multer.File, dto: UploadMediaDto, req: any): Promise<{
        id: string;
        url: string;
        thumbnailUrl: string;
        duration: number;
        width: number;
        height: number;
        fileSize: number;
        mimeType: string;
    }>;
    uploadBatch(files: Express.Multer.File[], dto: UploadMediaDto, req: any): Promise<{
        files: any[];
        totalUploaded: number;
        failed: any[];
    } | {
        files: any[];
        totalUploaded: number;
        failed: any[];
        statusCode: number;
    }>;
    deleteMedia(id: string, req: any): Promise<{
        message: string;
        id: string;
    }>;
    getUserMedia(userId: string, category: string, query: GetMediaQueryDto): Promise<{
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
}
