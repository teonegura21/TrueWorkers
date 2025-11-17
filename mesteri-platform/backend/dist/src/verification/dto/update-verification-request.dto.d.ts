import { VerificationRequestStatus, VerificationRequestType } from '@prisma/client';
export declare class UpdateVerificationRequestDto {
    status?: VerificationRequestStatus;
    notes?: string;
    type?: VerificationRequestType;
}
