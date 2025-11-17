import { Module, MiddlewareConsumer, NestModule } from '@nestjs/common';
import { MulterModule } from '@nestjs/platform-express';
import { MediaController } from './media.controller';
import { MediaUploadService } from './media-upload.service';
import { FileValidationMiddleware } from './middleware/file-validation.middleware';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [
    PrismaModule,
    MulterModule.register({
      storage: 'memory',
      limits: {
        fileSize: 104857600, // 100MB max
      },
    }),
  ],
  controllers: [MediaController],
  providers: [MediaUploadService, FileValidationMiddleware],
  exports: [MediaUploadService],
})
export class MediaModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(FileValidationMiddleware)
      .forRoutes(MediaController);
  }
}
