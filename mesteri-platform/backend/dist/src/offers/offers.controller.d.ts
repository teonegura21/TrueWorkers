import { OffersService } from './offers.service';
import { CreateOfferDto, UpdateOfferDto } from './offers.dtos';
export declare class OffersController {
    private readonly offersService;
    constructor(offersService: OffersService);
    findAll(): Promise<{
        id: string;
        createdAt: Date;
        jobId: string;
        craftsmanId: string;
        notes: string | null;
        bidAmount: number;
        estimatedDays: number;
    }[]>;
    findOne(id: string): Promise<{
        id: string;
        createdAt: Date;
        jobId: string;
        craftsmanId: string;
        notes: string | null;
        bidAmount: number;
        estimatedDays: number;
    }>;
    findByJobId(jobId: string): Promise<{
        id: string;
        createdAt: Date;
        jobId: string;
        craftsmanId: string;
        notes: string | null;
        bidAmount: number;
        estimatedDays: number;
    }[]>;
    findByCraftsmanId(craftsmanId: string): Promise<{
        id: string;
        createdAt: Date;
        jobId: string;
        craftsmanId: string;
        notes: string | null;
        bidAmount: number;
        estimatedDays: number;
    }[]>;
    create(offerData: CreateOfferDto, req: any): Promise<{
        id: string;
        createdAt: Date;
        jobId: string;
        craftsmanId: string;
        notes: string | null;
        bidAmount: number;
        estimatedDays: number;
    }>;
    update(id: string, updateData: UpdateOfferDto): Promise<{
        id: string;
        createdAt: Date;
        jobId: string;
        craftsmanId: string;
        notes: string | null;
        bidAmount: number;
        estimatedDays: number;
    }>;
    delete(id: string): Promise<void>;
    acceptOffer(id: string): Promise<{
        id: string;
        createdAt: Date;
        jobId: string;
        craftsmanId: string;
        notes: string | null;
        bidAmount: number;
        estimatedDays: number;
    }>;
    rejectOffer(id: string): Promise<{
        id: string;
        createdAt: Date;
        jobId: string;
        craftsmanId: string;
        notes: string | null;
        bidAmount: number;
        estimatedDays: number;
    }>;
    withdrawOffer(id: string, req: any): Promise<{
        id: string;
        createdAt: Date;
        jobId: string;
        craftsmanId: string;
        notes: string | null;
        bidAmount: number;
        estimatedDays: number;
    }>;
    getOfferStats(jobId: string): Promise<{
        totalOffers: number;
        averagePrice: number;
        minPrice: number;
        maxPrice: number;
    }>;
}
