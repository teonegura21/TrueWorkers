import { VerificationRequestType } from '@prisma/client';

export class CreateVerificationRequestDto {
  userId: string;
  type: VerificationRequestType;
  notes?: string;
}
