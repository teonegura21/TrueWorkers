import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersGeoService } from './users-geo.service';
import { UsersController } from './users.controller';

@Module({
  controllers: [UsersController],
  providers: [UsersService, UsersGeoService],
  exports: [UsersService, UsersGeoService],
})
export class UsersModule {}
