import { Module } from '@nestjs/common';
import { ContractsService } from './contracts.service';
import { ContractsController } from './contracts.controller';
import { DatabaseModule } from '../core/database/database.module';
import { SignRequestModule } from '../signrequest/signrequest.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { PdfService } from './pdf.service';

@Module({
  imports: [DatabaseModule, SignRequestModule, NotificationsModule],
  controllers: [ContractsController],
  providers: [ContractsService, PdfService],
  exports: [ContractsService],
})
export class ContractsModule {}
