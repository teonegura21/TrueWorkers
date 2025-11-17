import { JobCategory } from '@prisma/client';
export declare class CreateJobDto {
    title: string;
    description: string;
    category: JobCategory;
    location: string;
    budgetMin: number;
    budgetMax: number;
    clientId: string;
}
