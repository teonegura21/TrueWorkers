import { StorageService } from './storage.service';
import { RequestSignedUrlDto } from './dto/request-signed-url.dto';
interface RequestUser {
    user: {
        userId: string;
    };
}
export declare class StorageController {
    private readonly storageService;
    constructor(storageService: StorageService);
    createSignedUrl(dto: RequestSignedUrlDto, req: RequestUser): Promise<{
        attachmentId: string;
        uploadUrl: string;
        bucket: string;
        objectPath: string;
        expiresAt: string;
    }>;
}
export {};
