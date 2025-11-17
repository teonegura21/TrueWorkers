import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Offer } from '@prisma/client';
import { CreateOfferDto, UpdateOfferDto } from './offers.dtos';

export { CreateOfferDto, UpdateOfferDto };

@Injectable()
export class OffersService {
  constructor(private prisma: PrismaService) {}

  async findAll(): Promise<Offer[]> {
    return this.prisma.offer.findMany({
      include: {
        job: true,
        craftsman: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string): Promise<Offer> {
    const offer = await this.prisma.offer.findUnique({
      where: { id },
      include: {
        job: true,
        craftsman: true,
      },
    });
    if (!offer) {
      throw new NotFoundException(`Offer with ID ${id} not found`);
    }
    return offer;
  }

  async findByJobId(jobId: string): Promise<Offer[]> {
    return this.prisma.offer.findMany({
      where: { jobId },
      include: {
        job: true,
        craftsman: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findByCraftsmanId(craftsmanId: string): Promise<Offer[]> {
    return this.prisma.offer.findMany({
      where: { craftsmanId },
      include: {
        job: true,
        craftsman: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(
    offerData: CreateOfferDto & { craftsmanId: string },
  ): Promise<Offer> {
    // Handle bidAmount field properly
    const bidAmount = offerData.bidAmount || offerData.proposedPrice;
    if (!bidAmount) {
      throw new BadRequestException(
        'Either bidAmount or proposedPrice must be provided',
      );
    }

    // Business logic: Check if craftsman already submitted an offer for this job
    const existingOffer = await this.prisma.offer.findFirst({
      where: {
        jobId: offerData.jobId,
        craftsmanId: offerData.craftsmanId,
      },
    });

    if (existingOffer) {
      throw new BadRequestException(
        'You have already submitted an offer for this job',
      );
    }

    const { proposedPrice, ...restData } = offerData;

    return this.prisma.offer.create({
      data: {
        bidAmount: bidAmount,
        jobId: offerData.jobId,
        craftsmanId: offerData.craftsmanId,
        estimatedDays: offerData.estimatedDays,
        notes: offerData.description || '', // Map description to notes field
        // Note: attachments not in current schema
      },
      include: {
        job: true,
        craftsman: true,
      },
    });
  }

  async update(id: string, updateData: UpdateOfferDto): Promise<Offer> {
    const offer = await this.findOne(id);

    // Convert proposedPrice to bidAmount if present in update data
    const { proposedPrice, ...prismaUpdateData } = updateData;

    return this.prisma.offer.update({
      where: { id },
      data: {
        ...prismaUpdateData,
        ...(proposedPrice && { bidAmount: proposedPrice }),
      },
      include: {
        job: true,
        craftsman: true,
      },
    });
  }

  async delete(id: string): Promise<void> {
    try {
      await this.prisma.offer.delete({
        where: { id },
      });
    } catch (error) {
      throw new NotFoundException(`Offer with ID ${id} not found`);
    }
  }

  async getOfferStats(jobId: string): Promise<{
    totalOffers: number;
    averagePrice: number;
    minPrice: number;
    maxPrice: number;
  }> {
    const offers = await this.prisma.offer.findMany({
      where: { jobId },
      select: {
        bidAmount: true,
      },
    });

    const totalOffers = offers.length;
    const prices = offers.map((o) => o.bidAmount);

    return {
      totalOffers,
      averagePrice:
        prices.length > 0
          ? prices.reduce((a, b) => a + b, 0) / prices.length
          : 0,
      minPrice: prices.length > 0 ? Math.min(...prices) : 0,
      maxPrice: prices.length > 0 ? Math.max(...prices) : 0,
    };
  }

  /**
   * Placeholder methods for workflow management
   * Note: Status field is not implemented in current Prisma schema
   * These will need to be enhanced when status tracking is added
   */
  async acceptOffer(id: string): Promise<Offer> {
    // For now, just return the offer as status management needs schema updates
    return this.findOne(id);
  }

  async rejectOffer(id: string): Promise<Offer> {
    // For now, just return the offer as status management needs schema updates
    return this.findOne(id);
  }

  async withdrawOffer(id: string, craftsmanId: string): Promise<Offer> {
    const offer = await this.findOne(id);

    // Business logic: Only allow creator to withdraw
    if (offer.craftsmanId !== craftsmanId) {
      throw new BadRequestException('You can only withdraw your own offers');
    }

    // Delete the offer since status tracking is not implemented yet
    await this.delete(id);
    return offer;
  }
}
