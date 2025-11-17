import { PrismaService } from '../prisma/prisma.service';
import { RequestSignedUrlDto } from './dto/request-signed-url.dto';
export declare class StorageService {
    private readonly prisma;
    private readonly storageEnabled;
    private readonly storage;
    private readonly bucketPrefix;
    private readonly defaultTtlMs;
    constructor(prisma: PrismaService);
    createUploadUrl(userId: string, dto: RequestSignedUrlDto): Promise<{
        attachmentId: string;
        uploadUrl: string;
        bucket: string;
        objectPath: string;
        expiresAt: string;
    }>;
    private resolveBucketName;
    private buildObjectPath;
    private extensionFromMime;
}
