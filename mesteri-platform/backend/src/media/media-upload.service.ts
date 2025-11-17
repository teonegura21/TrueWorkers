import {
  Injectable,
  InternalServerErrorException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import sharp from 'sharp';
import ffmpeg from 'fluent-ffmpeg';
import ffmpegStatic from 'ffmpeg-static';
import { v4 as uuidv4 } from 'uuid';
import * as fs from 'fs/promises';
import * as path from 'path';
import { MediaCategory } from './dto';

// Set ffmpeg path
if (ffmpegStatic && typeof ffmpegStatic === 'string') {
  ffmpeg.setFfmpegPath(ffmpegStatic);
}

export enum MediaFileType {
  IMAGE = 'IMAGE',
  VIDEO = 'VIDEO',
}

export enum MediaStatus {
  PROCESSING = 'PROCESSING',
  ACTIVE = 'ACTIVE',
  FAILED = 'FAILED',
  DELETED = 'DELETED',
}

interface ProcessedImage {
  originalUrl: string;
  thumbnailUrl: string;
  mediumUrl: string;
  width: number;
  height: number;
  fileSize: number;
}

interface ProcessedVideo {
  url: string;
  thumbnailUrl: string;
  width: number;
  height: number;
  duration: number;
  fileSize: number;
}

interface MediaMetadata {
  width?: number;
  height?: number;
  duration?: number;
}

@Injectable()
export class MediaUploadService {
  private readonly logger = new Logger(MediaUploadService.name);
  private readonly uploadPath =
    process.env.UPLOAD_PATH || './storage/uploads';
  private readonly imageQuality = parseInt(process.env.IMAGE_QUALITY || '85');
  private readonly thumbnailSize = parseInt(
    process.env.THUMBNAIL_SIZE || '300',
  );
  private readonly mediumSize = parseInt(process.env.MEDIUM_SIZE || '800');
  private readonly maxVideoDuration = parseInt(
    process.env.MAX_VIDEO_DURATION || '300',
  );

  constructor(private readonly prisma: PrismaService) {}

  async uploadImage(
    file: Express.Multer.File,
    userId: string,
    category: MediaCategory,
    entityId?: string,
  ) {
    try {
      const processed = await this.processImage(file, userId, category);

      // Validate dimensions
      if (processed.width < 400 || processed.height < 400) {
        throw new BadRequestException(
          'Image dimensions must be at least 400x400 pixels.',
        );
      }

      if (processed.width > 4000 || processed.height > 4000) {
        throw new BadRequestException(
          'Image dimensions must not exceed 4000x4000 pixels.',
        );
      }

      const attachment = await this.prisma.attachment.create({
        data: {
          bucket: 'mesteri-media', // Use hardcoded value since bucketPrefix property doesn't exist
          objectPath: processed.originalUrl.replace('./storage/uploads/', ''), // Store relative path
          contentType: file.mimetype,
          fileSize: processed.fileSize,
          checksumSha256: '', // TODO: Implement checksum
          uploadedById: userId,
          retentionPolicyId: 'default-policy', // TODO: Use actual policy ID
          status: 'ACTIVE', // Use string literal that matches schema enum
        },
      });

      // Create the attachment link
      await this.prisma.attachmentLink.create({
        data: {
          attachmentId: attachment.id,
          entityType: 'MESSAGE', // Use string literal that matches schema enum
          entityId: entityId || 'unknown',
          role: 'media',
        },
      });

      // Create a media object with the expected properties for return
      const mediaAttachment = {
        id: attachment.id,
        fileUrl: `./storage/uploads/${attachment.objectPath}`, // Reconstruct the full URL
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
    } catch (error) {
      this.logger.error('Image upload failed', error);
      throw error;
    }
  }

  async uploadVideo(
    file: Express.Multer.File,
    userId: string,
    category: MediaCategory,
    entityId?: string,
  ) {
    try {
      const processed = await this.processVideo(file, userId, category);

      // Validate duration
      if (processed.duration > this.maxVideoDuration) {
        throw new BadRequestException(
          `Video duration must not exceed ${this.maxVideoDuration} seconds.`,
        );
      }

      const attachment = await this.prisma.attachment.create({
        data: {
          bucket: 'mesteri-media',
          objectPath: processed.url.replace('./storage/uploads/', ''), // Store relative path
          contentType: 'video/mp4',
          fileSize: processed.fileSize,
          checksumSha256: '', // TODO: Implement checksum
          uploadedById: userId,
          retentionPolicyId: 'default-policy', // TODO: Use actual policy ID
          status: 'ACTIVE', // Use string literal that matches schema enum
        },
      });

      // Create the attachment link
      await this.prisma.attachmentLink.create({
        data: {
          attachmentId: attachment.id,
          entityType: 'MESSAGE', // Use string literal that matches schema enum
          entityId: entityId || 'unknown',
          role: 'media',
        },
      });

      // Create a media object with the expected properties for return
      const mediaAttachment = {
        id: attachment.id,
        url: `./storage/uploads/${attachment.objectPath}`, // Reconstruct the full URL
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
    } catch (error) {
      this.logger.error('Video upload failed', error);
      throw error;
    }
  }

  async uploadMultiple(
    files: Express.Multer.File[],
    userId: string,
    category: MediaCategory,
    entityId?: string,
  ) {
    const results = [];
    const failed = [];

    for (const file of files) {
      try {
        const isImage = file.mimetype.startsWith('image/');
        const result = isImage
          ? await this.uploadImage(file, userId, category, entityId)
          : await this.uploadVideo(file, userId, category, entityId);
        results.push(result);
      } catch (error: any) {
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

  async deleteFile(id: string, userId: string) {
    const media = await this.prisma.attachment.findUnique({
      where: { id },
    });

    if (!media) {
      throw new BadRequestException('Media not found');
    }

    if (media.uploadedById !== userId) {
      throw new BadRequestException('Not authorized to delete this media');
    }

    // Delete physical files
    try {
      const basePath = path.join(process.cwd(), this.uploadPath);
      await fs.unlink(path.join(basePath, media.objectPath));
      // Assuming thumbnails and medium versions are stored with similar path patterns
      // In a real implementation, these would need to be properly tracked
      const thumbnailPath = media.objectPath.replace('.', '-thumb.');
      const mediumPath = media.objectPath.replace('.', '-medium.');
      try {
        await fs.unlink(path.join(basePath, thumbnailPath));
      } catch (e) {
        // Thumbnail may not exist, that's OK
      }
      try {
        await fs.unlink(path.join(basePath, mediumPath));
      } catch (e) {
        // Medium version may not exist, that's OK
      }
    } catch (error) {
      this.logger.error('Failed to delete physical files', error);
    }

    // Soft delete in database
    await this.prisma.attachment.update({
      where: { id },
      data: { status: MediaStatus.DELETED },
    });

    return { message: 'Media deleted successfully', id };
  }

  async getUserMedia(
    userId: string,
    category: MediaCategory,
    page: number = 1,
    limit: number = 20,
    sortBy: string = 'createdAt',
    order: 'asc' | 'desc' = 'desc',
  ) {
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

  private async processImage(
    file: Express.Multer.File,
    userId: string,
    category: MediaCategory,
  ): Promise<ProcessedImage> {
    const filename = this.generateFilename(file.originalname);
    const categoryPath = category.toLowerCase();
    const dir = path.join(
      process.cwd(),
      this.uploadPath,
      'images',
      categoryPath,
      userId,
    );

    // Ensure directory exists
    await fs.mkdir(dir, { recursive: true });

    // Process original image
    const originalPath = path.join(dir, `${filename}-original.jpg`);
    const thumbnailPath = path.join(dir, `${filename}-thumb.jpg`);
    const mediumPath = path.join(dir, `${filename}-medium.jpg`);

    const image = sharp(file.buffer);
    const metadata = await image.metadata();

    // Save optimized original
    await image
      .jpeg({ quality: this.imageQuality })
      .toFile(originalPath);

    // Generate thumbnail (300x300)
    await sharp(file.buffer)
      .resize(this.thumbnailSize, this.thumbnailSize, { fit: 'cover' })
      .jpeg({ quality: 80 })
      .toFile(thumbnailPath);

    // Generate medium size (800x800)
    await sharp(file.buffer)
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

  private async processVideo(
    file: Express.Multer.File,
    userId: string,
    category: MediaCategory,
  ): Promise<ProcessedVideo> {
    const filename = this.generateFilename(file.originalname);
    const categoryPath = category.toLowerCase();
    const dir = path.join(
      process.cwd(),
      this.uploadPath,
      'videos',
      categoryPath,
      userId,
    );

    // Ensure directory exists
    await fs.mkdir(dir, { recursive: true });

    // Save original file first to process it
    const tempPath = path.join(dir, `temp-${filename}.mp4`);
    await fs.writeFile(tempPath, file.buffer);

    const outputPath = path.join(dir, `${filename}.mp4`);
    const thumbnailPath = path.join(dir, `${filename}-thumb.jpg`);

    try {
      // Get video metadata
      const metadata = await this.getVideoMetadata(tempPath);

      // Compress video to 720p
      await this.compressVideo(tempPath, outputPath);

      // Extract thumbnail at 1 second
      await this.extractVideoThumbnail(outputPath, thumbnailPath);

      // Delete temp file
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
    } catch (error) {
      // Clean up on error
      try {
        await fs.unlink(tempPath);
      } catch {}
      throw new InternalServerErrorException('Video processing failed');
    }
  }

  private async getVideoMetadata(filePath: string): Promise<MediaMetadata> {
    return new Promise((resolve, reject) => {
      ffmpeg.ffprobe(filePath, (err, metadata) => {
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

  private async compressVideo(
    inputPath: string,
    outputPath: string,
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
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

  private async extractVideoThumbnail(
    videoPath: string,
    thumbnailPath: string,
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      ffmpeg(videoPath)
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

  private generateFilename(originalName: string): string {
    const uuid = uuidv4();
    const timestamp = new Date()
      .toISOString()
      .replace(/[:.]/g, '-')
      .substring(0, 19);
    return `${uuid}-${timestamp}`;
  }
}
