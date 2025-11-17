import { PrismaService } from '../../../prisma/prisma.service';
export declare class DatabaseSeeder {
    private readonly prisma;
    constructor(prisma: PrismaService);
    seed(): Promise<void>;
    private seedUsers;
    private seedJobs;
}
