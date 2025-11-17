export declare class CreateOfferDto {
    jobId: string;
    bidAmount: number;
    description: string;
    estimatedDays: number;
    attachments?: string[];
    proposedPrice?: number;
}
export declare class UpdateOfferDto {
    proposedPrice?: number;
    description?: string;
    estimatedDays?: number;
    attachments?: string[];
}
