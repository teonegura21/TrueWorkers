import { NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
export declare class FileValidationMiddleware implements NestMiddleware {
    private readonly MAX_IMAGE_SIZE;
    private readonly MAX_VIDEO_SIZE;
    private readonly MAX_BATCH_FILES;
    private readonly ALLOWED_IMAGE_MIMES;
    private readonly ALLOWED_VIDEO_MIMES;
    private readonly IMAGE_EXTENSIONS;
    private readonly VIDEO_EXTENSIONS;
    use(req: Request, res: Response, next: NextFunction): void;
    private validateSingleFile;
    private validateBatchFiles;
}
