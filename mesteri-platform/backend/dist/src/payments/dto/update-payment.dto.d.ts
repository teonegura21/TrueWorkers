import { PaymentStatus, PaymentMethod } from '@prisma/client';
export declare class UpdatePaymentDto {
    amount?: number;
    currency?: string;
    status?: PaymentStatus;
    method?: PaymentMethod;
}
