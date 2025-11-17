import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Notification } from '@prisma/client';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId?: string): Promise<Notification[]> {
    const where = userId ? { userId } : {};
    return this.prisma.notification.findMany({
      where,
      include: {
        user: true,
        job: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string, userId?: string): Promise<Notification> {
    const where = userId ? { id, userId } : { id };
    const notification = await this.prisma.notification.findFirst({
      where,
      include: {
        user: true,
        job: true,
      },
    });
    if (!notification) {
      throw new NotFoundException(`Notification with ID ${id} not found`);
    }
    return notification;
  }

  async create(
    createNotificationDto: CreateNotificationDto,
  ): Promise<Notification> {
    return this.prisma.notification.create({
      data: createNotificationDto,
      include: {
        user: true,
        job: true,
      },
    });
  }

  async update(
    id: string,
    updateNotificationDto: UpdateNotificationDto,
    userId?: string,
  ): Promise<Notification> {
    try {
      return await this.prisma.notification.update({
        where: { id },
        data: updateNotificationDto,
        include: {
          user: true,
          job: true,
        },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Notification with ID ${id} not found`);
      }
      throw error;
    }
  }

  async delete(id: string, userId?: string): Promise<void> {
    try {
      await this.prisma.notification.delete({ where: { id } });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Notification with ID ${id} not found`);
      }
      throw error;
    }
  }

  async markAsRead(id: string, userId?: string): Promise<Notification> {
    return this.update(id, { isRead: true }, userId);
  }

  async findUnread(userId: string): Promise<Notification[]> {
    return this.findAll(userId).then((notifications) =>
      notifications.filter((n) => !n.isRead),
    );
  }
}
