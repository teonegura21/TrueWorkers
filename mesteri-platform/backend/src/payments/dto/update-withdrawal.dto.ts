import { WithdrawalStatus } from '@prisma/client';

export class UpdateWithdrawalDto {
  amount?: number;
  currency?: string;
  status?: WithdrawalStatus;
}
