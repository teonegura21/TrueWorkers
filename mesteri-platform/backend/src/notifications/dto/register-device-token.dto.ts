import { IsEnum, IsNotEmpty, IsString } from 'class-validator';

export enum DevicePlatform {
  IOS = 'IOS',
  ANDROID = 'ANDROID',
  WEB = 'WEB',
}

export class RegisterDeviceTokenDto {
  @IsString()
  @IsNotEmpty()
  token: string;

  @IsEnum(DevicePlatform)
  @IsNotEmpty()
  platform: DevicePlatform;
}
