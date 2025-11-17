import { PaymentStatus, PaymentMethod } from '@prisma/client';
export declare class CreatePaymentDto {
    amount: number;
    currency: string;
    status: PaymentStatus;
    method: PaymentMethod;
    userId: string;
    projectId: string;
    masterId: string;
    clientId: string;
}
