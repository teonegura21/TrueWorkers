import { WithdrawalStatus } from '@prisma/client';
export declare class CreateWithdrawalDto {
    walletId: string;
    amount: number;
    currency: string;
    status: WithdrawalStatus;
    userId: string;
}
