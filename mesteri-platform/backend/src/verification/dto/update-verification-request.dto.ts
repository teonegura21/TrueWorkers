import { VerificationRequestStatus, VerificationRequestType } from '@prisma/client';

export class UpdateVerificationRequestDto {
  status?: VerificationRequestStatus;
  notes?: string;
  type?: VerificationRequestType;
}
