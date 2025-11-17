import { PrismaService } from '../prisma/prisma.service';
import { Notification } from '@prisma/client';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';
export declare class NotificationsService {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(userId?: string): Promise<Notification[]>;
    findOne(id: string, userId?: string): Promise<Notification>;
    create(createNotificationDto: CreateNotificationDto): Promise<Notification>;
    update(id: string, updateNotificationDto: UpdateNotificationDto, userId?: string): Promise<Notification>;
    delete(id: string, userId?: string): Promise<void>;
    markAsRead(id: string, userId?: string): Promise<Notification>;
    findUnread(userId: string): Promise<Notification[]>;
}
