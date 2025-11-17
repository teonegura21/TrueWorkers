import { WithdrawalStatus } from '@prisma/client';
export declare class UpdateWithdrawalDto {
    amount?: number;
    currency?: string;
    status?: WithdrawalStatus;
}
