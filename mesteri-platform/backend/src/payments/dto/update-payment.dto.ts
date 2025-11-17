import { PaymentStatus, PaymentMethod } from '@prisma/client';

export class UpdatePaymentDto {
  amount?: number;
  currency?: string;
  status?: PaymentStatus;
  method?: PaymentMethod;
}
