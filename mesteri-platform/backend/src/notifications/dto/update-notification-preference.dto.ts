import { IsBoolean, IsEnum, IsNotEmpty, IsOptional } from 'class-validator';

export enum NotificationType {
  NEW_JOB = 'NEW_JOB',
  OFFER_ACCEPTED = 'OFFER_ACCEPTED',
  CONTRACT_SIGNED = 'CONTRACT_SIGNED',
  PAYMENT_RECEIVED = 'PAYMENT_RECEIVED',
  NEW_MESSAGE = 'NEW_MESSAGE',
  WELCOME = 'WELCOME',
  PROJECT_COMPLETED = 'PROJECT_COMPLETED',
  OFFER_SUBMITTED = 'OFFER_SUBMITTED',
}

export class UpdateNotificationPreferenceDto {
  @IsEnum(NotificationType)
  @IsNotEmpty()
  notificationType: NotificationType;

  @IsBoolean()
  @IsOptional()
  pushEnabled?: boolean;

  @IsBoolean()
  @IsOptional()
  emailEnabled?: boolean;
}
