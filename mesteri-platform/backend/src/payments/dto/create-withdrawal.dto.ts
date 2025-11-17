import { WithdrawalStatus } from '@prisma/client';

export class CreateWithdrawalDto {
  walletId: string;
  amount: number;
  currency: string;
  status: WithdrawalStatus;
  userId: string;
}
