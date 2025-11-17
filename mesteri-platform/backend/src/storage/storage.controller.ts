import { Body, Controller, Post, Request, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../guards/firebase-auth.guard';
import { StorageService } from './storage.service';
import { RequestSignedUrlDto } from './dto/request-signed-url.dto';

interface RequestUser {
  user: { userId: string };
}

@Controller('storage')
@UseGuards(FirebaseAuthGuard)
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  @Post('signed-url')
  async createSignedUrl(
    @Body() dto: RequestSignedUrlDto,
    @Request() req: RequestUser,
  ) {
    return this.storageService.createUploadUrl(req.user.userId, dto);
  }
}
