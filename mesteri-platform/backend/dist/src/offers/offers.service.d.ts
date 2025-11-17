import { PrismaService } from '../prisma/prisma.service';
import { Offer } from '@prisma/client';
import { CreateOfferDto, UpdateOfferDto } from './offers.dtos';
export { CreateOfferDto, UpdateOfferDto };
export declare class OffersService {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(): Promise<Offer[]>;
    findOne(id: string): Promise<Offer>;
    findByJobId(jobId: string): Promise<Offer[]>;
    findByCraftsmanId(craftsmanId: string): Promise<Offer[]>;
    create(offerData: CreateOfferDto & {
        craftsmanId: string;
    }): Promise<Offer>;
    update(id: string, updateData: UpdateOfferDto): Promise<Offer>;
    delete(id: string): Promise<void>;
    getOfferStats(jobId: string): Promise<{
        totalOffers: number;
        averagePrice: number;
        minPrice: number;
        maxPrice: number;
    }>;
    acceptOffer(id: string): Promise<Offer>;
    rejectOffer(id: string): Promise<Offer>;
    withdrawOffer(id: string, craftsmanId: string): Promise<Offer>;
}
