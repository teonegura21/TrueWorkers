import { Module } from '@nestjs/common';
import { SignRequestService } from './signrequest.service';

@Module({
  providers: [SignRequestService],
  exports: [SignRequestService],
})
export class SignRequestModule {}
