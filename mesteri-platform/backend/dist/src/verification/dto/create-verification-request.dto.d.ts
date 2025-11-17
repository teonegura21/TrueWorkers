import { VerificationRequestType } from '@prisma/client';
export declare class CreateVerificationRequestDto {
    userId: string;
    type: VerificationRequestType;
    notes?: string;
}
