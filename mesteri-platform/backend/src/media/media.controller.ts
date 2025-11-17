import {
  Controller,
  Post,
  Delete,
  Get,
  Param,
  Query,
  Body,
  UploadedFile,
  UploadedFiles,
  UseInterceptors,
  UseGuards,
  Request,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { MediaUploadService } from './media-upload.service';
import { UploadMediaDto, GetMediaQueryDto, MediaCategory } from './dto';
import { FirebaseAuthGuard } from '../guards/firebase-auth.guard';
import { FirebaseAuthenticatedRequest } from '../notifications/interfaces/auth-request.interface';

@Controller('media')
@UseGuards(FirebaseAuthGuard)
export class MediaController {
  constructor(private readonly mediaUploadService: MediaUploadService) {}

  @Post('upload/image')
  @UseInterceptors(FileInterceptor('file'))
  async uploadImage(
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: UploadMediaDto,
    @Request() req: FirebaseAuthenticatedRequest,
  ) {
    if (!file) {
      throw new BadRequestException('No file provided');
    }

    const userId = req.user.uid;
    return this.mediaUploadService.uploadImage(
      file,
      userId,
      dto.category,
      dto.entityId,
    );
  }

  @Post('upload/video')
  @UseInterceptors(FileInterceptor('file'))
  async uploadVideo(
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: UploadMediaDto,
    @Request() req: FirebaseAuthenticatedRequest,
  ) {
    if (!file) {
      throw new BadRequestException('No file provided');
    }

    const userId = req.user.uid;
    return this.mediaUploadService.uploadVideo(
      file,
      userId,
      dto.category,
      dto.entityId,
    );
  }

  @Post('upload/batch')
  @UseInterceptors(FilesInterceptor('files', 10))
  async uploadBatch(
    @UploadedFiles() files: Express.Multer.File[],
    @Body() dto: UploadMediaDto,
    @Request() req: FirebaseAuthenticatedRequest,
  ) {
    if (!files || files.length === 0) {
      throw new BadRequestException('No files provided');
    }

    const userId = req.user.uid;
    const result = await this.mediaUploadService.uploadMultiple(
      files,
      userId,
      dto.category,
      dto.entityId,
    );

    // Return 207 if there are failures
    if (result.failed.length > 0) {
      return {
        statusCode: 207,
        ...result,
      };
    }

    return result;
  }

  @Delete(':id')
  async deleteMedia(@Param('id') id: string, @Request() req: FirebaseAuthenticatedRequest) {
    const userId = req.user.uid;
    return this.mediaUploadService.deleteFile(id, userId);
  }

  @Get(':userId/:category')
  async getUserMedia(
    @Param('userId') userId: string,
    @Param('category') category: string,
    @Query() query: GetMediaQueryDto,
  ) {
    // Validate category
    if (!Object.values(MediaCategory).includes(category as MediaCategory)) {
      throw new BadRequestException('Invalid category');
    }

    return this.mediaUploadService.getUserMedia(
      userId,
      category as MediaCategory,
      query.page,
      query.limit,
      query.sortBy,
      query.order,
    );
  }
}
