import {
  Injectable,
  NestMiddleware,
  BadRequestException,
} from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class FileValidationMiddleware implements NestMiddleware {
  private readonly MAX_IMAGE_SIZE = parseInt(
    process.env.MAX_IMAGE_SIZE || '10485760',
  ); // 10MB
  private readonly MAX_VIDEO_SIZE = parseInt(
    process.env.MAX_VIDEO_SIZE || '104857600',
  ); // 100MB
  private readonly MAX_BATCH_FILES = parseInt(
    process.env.MAX_BATCH_FILES || '10',
  );

  private readonly ALLOWED_IMAGE_MIMES = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];
  private readonly ALLOWED_VIDEO_MIMES = [
    'video/mp4',
    'video/quicktime',
    'video/x-msvideo',
  ];

  private readonly IMAGE_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.webp'];
  private readonly VIDEO_EXTENSIONS = ['.mp4', '.mov', '.avi'];

  use(req: Request, res: Response, next: NextFunction) {
    const files = req.files as Express.Multer.File[];
    const file = req.file as Express.Multer.File;

    if (!files && !file) {
      return next();
    }

    try {
      if (files && Array.isArray(files)) {
        this.validateBatchFiles(files);
      } else if (file) {
        this.validateSingleFile(file);
      }
      next();
    } catch (error) {
      next(error);
    }
  }

  private validateSingleFile(file: Express.Multer.File) {
    const errors: string[] = [];

    // Validate file type
    if (
      !this.ALLOWED_IMAGE_MIMES.includes(file.mimetype) &&
      !this.ALLOWED_VIDEO_MIMES.includes(file.mimetype)
    ) {
      errors.push(
        'Unsupported file type. Please use JPG, PNG, WEBP for images or MP4, MOV, AVI for videos.',
      );
    }

    // Validate file size
    const isImage = this.ALLOWED_IMAGE_MIMES.includes(file.mimetype);
    const isVideo = this.ALLOWED_VIDEO_MIMES.includes(file.mimetype);
    const maxSize = isImage ? this.MAX_IMAGE_SIZE : this.MAX_VIDEO_SIZE;

    if (file.size > maxSize) {
      const maxSizeMB = maxSize / 1024 / 1024;
      errors.push(
        `File size exceeds maximum of ${maxSizeMB}MB for ${isImage ? 'images' : 'videos'}.`,
      );
    }

    // Validate file extension
    const fileExt = file.originalname
      .substring(file.originalname.lastIndexOf('.'))
      .toLowerCase();
    const allowedExtensions = isImage
      ? this.IMAGE_EXTENSIONS
      : this.VIDEO_EXTENSIONS;

    if (!allowedExtensions.includes(fileExt)) {
      errors.push(
        `Invalid file extension. Allowed: ${allowedExtensions.join(', ')}`,
      );
    }

    if (errors.length > 0) {
      throw new BadRequestException({
        statusCode: 400,
        message: 'File validation failed',
        errors,
      });
    }
  }

  private validateBatchFiles(files: Express.Multer.File[]) {
    if (files.length > this.MAX_BATCH_FILES) {
      throw new BadRequestException(
        `Maximum ${this.MAX_BATCH_FILES} files allowed per batch upload.`,
      );
    }

    const errors: string[] = [];
    files.forEach((file, index) => {
      try {
        this.validateSingleFile(file);
      } catch (error: unknown) {
        if (error.response?.errors) {
          errors.push(
            `File ${index + 1} (${file.originalname}): ${error.response.errors.join(', ')}`,
          );
        }
      }
    });

    if (errors.length > 0) {
      throw new BadRequestException({
        statusCode: 400,
        message: 'Batch file validation failed',
        errors,
      });
    }
  }
}
