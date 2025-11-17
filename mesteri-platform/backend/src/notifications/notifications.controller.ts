import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  Req,
  HttpCode,
  HttpStatus,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { PushNotificationService } from './push-notification.service';
import { Notification } from '@prisma/client';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';
import { RegisterDeviceTokenDto } from './dto/register-device-token.dto';
import { RemoveDeviceTokenDto } from './dto/remove-device-token.dto';
import { TestPushNotificationDto } from './dto/test-push-notification.dto';
import { UpdateNotificationPreferenceDto } from './dto/update-notification-preference.dto';
import { FirebaseAuthenticatedRequest } from './interfaces/auth-request.interface';
import { FirebaseAuthGuard } from '../guards/firebase-auth.guard';
import { PrismaService } from '../prisma/prisma.service';

@Controller('notifications')
@UseGuards(FirebaseAuthGuard)
export class NotificationsController {
  constructor(
    private readonly notificationsService: NotificationsService,
    private readonly pushNotificationService: PushNotificationService,
    private readonly prisma: PrismaService,
  ) {}

  @Get()
  findAll(@Query('userId') userId?: string) {
    return this.notificationsService.findAll(userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Query('userId') userId?: string) {
    return this.notificationsService.findOne(id, userId);
  }

  @Post()
  create(@Body() createNotificationDto: CreateNotificationDto) {
    return this.notificationsService.create(createNotificationDto);
  }

  @Put(':id')
  update(
    @Param('id') id: string,
    @Body() updateNotificationDto: UpdateNotificationDto,
    @Query('userId') userId?: string,
  ) {
    return this.notificationsService.update(id, updateNotificationDto, userId);
  }

  @Delete(':id')
  delete(@Param('id') id: string, @Query('userId') userId?: string) {
    return this.notificationsService.delete(id, userId);
  }

  @Put(':id/read')
  markAsRead(@Param('id') id: string, @Query('userId') userId?: string) {
    return this.notificationsService.markAsRead(id, userId);
  }

  @Get('unread')
  findUnread(@Query('userId') userId: string) {
    return this.notificationsService.findUnread(userId);
  }

  // New endpoints for push notifications and preferences

  @Post('register-token')
  @HttpCode(HttpStatus.CREATED)
  async registerDeviceToken(
    @Body() dto: RegisterDeviceTokenDto,
    @Req() req: FirebaseAuthenticatedRequest,
  ) {
    const userId = req.user?.uid;
    if (!userId) {
      throw new UnauthorizedException('User not authenticated');
    }

    return await this.pushNotificationService.registerDeviceToken(
      userId,
      dto.token,
      dto.platform as any,
    );
  }

  @Post('remove-token')
  @HttpCode(HttpStatus.OK)
  async removeDeviceToken(
    @Body() dto: RemoveDeviceTokenDto,
    @Req() req: FirebaseAuthenticatedRequest,
  ) {
    const userId = req.user?.uid;
    if (!userId) {
      throw new UnauthorizedException('User not authenticated');
    }

    await this.pushNotificationService.removeDeviceToken(userId, dto.token);
    return { message: 'Device token removed successfully' };
  }

  @Post('test-push')
  @HttpCode(HttpStatus.OK)
  async testPushNotification(
    @Body() dto: TestPushNotificationDto,
    @Req() req: FirebaseAuthenticatedRequest,
  ) {
    // Check if user is admin (you'll need to implement role checking)
    const userId = req.user?.uid;
    if (!userId) {
      throw new UnauthorizedException('User not authenticated');
    }

    const user = await this.prisma.user.findUnique({
      where: { firebaseUid: userId },
    });

    if (!user || user.role !== 'ADMIN') {
      throw new UnauthorizedException(
        'Only admins can send test notifications',
      );
    }

    return await this.pushNotificationService.sendPushNotification(
      dto.userId,
      dto.title,
      dto.body,
      dto.data,
    );
  }

  @Get('history/:userId')
  async getNotificationHistory(
    @Param('userId') userId: string,
    @Req() req: FirebaseAuthenticatedRequest,
  ) {
    const authUserId = req.user?.uid;
    if (!authUserId) {
      throw new UnauthorizedException('User not authenticated');
    }

    // Verify user can only access their own history
    const user = await this.prisma.user.findUnique({
      where: { firebaseUid: authUserId },
    });

    if (!user || (user.id !== userId && user.role !== 'ADMIN')) {
      throw new UnauthorizedException(
        'You can only access your own notification history',
      );
    }

    return await this.prisma.notificationLog.findMany({
      where: { userId },
      orderBy: { sentAt: 'desc' },
      take: 50,
    });
  }

  @Get('preferences/:userId')
  async getNotificationPreferences(
    @Param('userId') userId: string,
    @Req() req: FirebaseAuthenticatedRequest,
  ) {
    const authUserId = req.user?.uid;
    if (!authUserId) {
      throw new UnauthorizedException('User not authenticated');
    }

    const user = await this.prisma.user.findUnique({
      where: { firebaseUid: authUserId },
    });

    if (!user || user.id !== userId) {
      throw new UnauthorizedException(
        'You can only access your own preferences',
      );
    }

    return await this.prisma.notificationPreference.findMany({
      where: { userId },
    });
  }

  @Put('preferences/:userId')
  async updateNotificationPreference(
    @Param('userId') userId: string,
    @Body() dto: UpdateNotificationPreferenceDto,
    @Req() req: FirebaseAuthenticatedRequest,
  ) {
    const authUserId = req.user?.uid;
    if (!authUserId) {
      throw new UnauthorizedException('User not authenticated');
    }

    const user = await this.prisma.user.findUnique({
      where: { firebaseUid: authUserId },
    });

    if (!user || user.id !== userId) {
      throw new UnauthorizedException(
        'You can only update your own preferences',
      );
    }

    // Upsert notification preference
    return await this.prisma.notificationPreference.upsert({
      where: {
        userId_notificationType: {
          userId,
          notificationType: dto.notificationType as any,
        },
      },
      update: {
        pushEnabled: dto.pushEnabled ?? undefined,
        emailEnabled: dto.emailEnabled ?? undefined,
      },
      create: {
        userId,
        notificationType: dto.notificationType as any,
        pushEnabled: dto.pushEnabled ?? true,
        emailEnabled: dto.emailEnabled ?? true,
      },
    });
  }

  @Get('unsubscribe/:token')
  async unsubscribeFromEmails(@Param('token') token: string) {
    // Simple implementation - you should use a more secure token mechanism
    // This is a placeholder - implement proper unsubscribe token generation
    try {
      const userId = Buffer.from(token, 'base64').toString('utf-8');

      await this.prisma.notificationPreference.updateMany({
        where: { userId },
        data: { emailEnabled: false },
      });

      return {
        message:
          'Successfully unsubscribed from email notifications. You can manage your preferences in the app settings.',
      };
    } catch (error) {
      throw new BadRequestException('Invalid unsubscribe token');
    }
  }
}
