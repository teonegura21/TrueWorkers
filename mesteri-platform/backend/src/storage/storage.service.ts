import {
  Injectable,
  InternalServerErrorException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { Storage, GetSignedUrlConfig } from '@google-cloud/storage';
import { PrismaService } from '../prisma/prisma.service';
import { RequestSignedUrlDto } from './dto/request-signed-url.dto';
import { AttachmentEntity, AttachmentStatus } from '@prisma/client';
import * as path from 'path';

@Injectable()
export class StorageService {
  private readonly storageEnabled: boolean;
  private readonly storage: Storage | null;
  private readonly bucketPrefix: string;
  private readonly defaultTtlMs: number;

  constructor(private readonly prisma: PrismaService) {
    this.storageEnabled = process.env.GCS_SIGNED_URLS !== 'disabled';
    this.bucketPrefix = process.env.MEDIA_BUCKET_PREFIX ?? 'mesteri-media';
    this.defaultTtlMs = Number(process.env.SIGNED_URL_TTL_MS ?? 15 * 60 * 1000);
    this.storage = this.storageEnabled ? new Storage() : null;
  }

  async createUploadUrl(userId: string, dto: RequestSignedUrlDto) {
    if (!this.storage || !this.storageEnabled) {
      throw new ServiceUnavailableException(
        'Signed URL service is not configured.',
      );
    }

    const bucketName = this.resolveBucketName(dto.bucketHint);
    const objectPath = this.buildObjectPath(dto, userId);
    const expires = Date.now() + this.defaultTtlMs;

    const bucket = this.storage.bucket(bucketName);
    const file = bucket.file(objectPath);

    const config: GetSignedUrlConfig = {
      action: 'write',
      expires,
      contentType: dto.contentType,
    };

    try {
      const [uploadUrl] = await file.getSignedUrl(config);
      const retentionPolicyCode =
        dto.entityType === AttachmentEntity.CONTRACT
          ? 'STANDARD_GUARANTEE'
          : 'SUPPORT_THREAD';

      // Find the retention policy by code
      const retentionPolicy = await this.prisma.retentionPolicy.findUnique({
        where: { code: retentionPolicyCode },
      });

      if (!retentionPolicy) {
        throw new InternalServerErrorException('Retention policy not found');
      }

      const attachment = await this.prisma.attachment.create({
        data: {
          bucket: bucketName,
          objectPath,
          contentType: dto.contentType,
          fileSize: 0,
          checksumSha256: 'pending',
          uploadedById: userId,
          retentionPolicyId: retentionPolicy.id, // Use retentionPolicyId directly
          status: AttachmentStatus.PENDING,
        },
      });

      return {
        attachmentId: attachment.id,
        uploadUrl,
        bucket: bucketName,
        objectPath,
        expiresAt: new Date(expires).toISOString(),
      };
    } catch (error) {
      throw new InternalServerErrorException('Unable to generate upload URL');
    }
  }

  private resolveBucketName(hint?: string) {
    if (hint) {
      return hint;
    }
    const env = process.env.APPLICATION_ENV ?? process.env.NODE_ENV ?? 'dev';
    return `${this.bucketPrefix}-${env}`;
  }

  private buildObjectPath(dto: RequestSignedUrlDto, userId: string) {
    const now = new Date();
    const ext =
      path.extname(dto.fileName) || this.extensionFromMime(dto.contentType);
    const safeBase = dto.fileName.replace(/[^\w\-. ]/g, '');
    const segment = (dto.entityType ?? AttachmentEntity.MESSAGE).toLowerCase();
    const timestamp = now.toISOString().replace(/[:.]/g, '-');
    return `${segment}/${userId}/${timestamp}-${safeBase}${ext}`;
  }

  private extensionFromMime(mime: string) {
    if (mime.includes('jpeg')) return '.jpg';
    if (mime.includes('png')) return '.png';
    if (mime.includes('pdf')) return '.pdf';
    return '';
  }
}
