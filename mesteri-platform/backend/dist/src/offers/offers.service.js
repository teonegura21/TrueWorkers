"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OffersService = exports.UpdateOfferDto = exports.CreateOfferDto = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const offers_dtos_1 = require("./offers.dtos");
Object.defineProperty(exports, "CreateOfferDto", { enumerable: true, get: function () { return offers_dtos_1.CreateOfferDto; } });
Object.defineProperty(exports, "UpdateOfferDto", { enumerable: true, get: function () { return offers_dtos_1.UpdateOfferDto; } });
let OffersService = class OffersService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll() {
        return this.prisma.offer.findMany({
            include: {
                job: true,
                craftsman: true,
            },
            orderBy: { createdAt: 'desc' },
        });
    }
    async findOne(id) {
        const offer = await this.prisma.offer.findUnique({
            where: { id },
            include: {
                job: true,
                craftsman: true,
            },
        });
        if (!offer) {
            throw new common_1.NotFoundException(`Offer with ID ${id} not found`);
        }
        return offer;
    }
    async findByJobId(jobId) {
        return this.prisma.offer.findMany({
            where: { jobId },
            include: {
                job: true,
                craftsman: true,
            },
            orderBy: { createdAt: 'desc' },
        });
    }
    async findByCraftsmanId(craftsmanId) {
        return this.prisma.offer.findMany({
            where: { craftsmanId },
            include: {
                job: true,
                craftsman: true,
            },
            orderBy: { createdAt: 'desc' },
        });
    }
    async create(offerData) {
        const bidAmount = offerData.bidAmount || offerData.proposedPrice;
        if (!bidAmount) {
            throw new common_1.BadRequestException('Either bidAmount or proposedPrice must be provided');
        }
        const existingOffer = await this.prisma.offer.findFirst({
            where: {
                jobId: offerData.jobId,
                craftsmanId: offerData.craftsmanId,
            },
        });
        if (existingOffer) {
            throw new common_1.BadRequestException('You have already submitted an offer for this job');
        }
        const { proposedPrice, ...restData } = offerData;
        return this.prisma.offer.create({
            data: {
                bidAmount: bidAmount,
                jobId: offerData.jobId,
                craftsmanId: offerData.craftsmanId,
                estimatedDays: offerData.estimatedDays,
                notes: offerData.description || '',
            },
            include: {
                job: true,
                craftsman: true,
            },
        });
    }
    async update(id, updateData) {
        const offer = await this.findOne(id);
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
    async delete(id) {
        try {
            await this.prisma.offer.delete({
                where: { id },
            });
        }
        catch (error) {
            throw new common_1.NotFoundException(`Offer with ID ${id} not found`);
        }
    }
    async getOfferStats(jobId) {
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
            averagePrice: prices.length > 0
                ? prices.reduce((a, b) => a + b, 0) / prices.length
                : 0,
            minPrice: prices.length > 0 ? Math.min(...prices) : 0,
            maxPrice: prices.length > 0 ? Math.max(...prices) : 0,
        };
    }
    async acceptOffer(id) {
        return this.findOne(id);
    }
    async rejectOffer(id) {
        return this.findOne(id);
    }
    async withdrawOffer(id, craftsmanId) {
        const offer = await this.findOne(id);
        if (offer.craftsmanId !== craftsmanId) {
            throw new common_1.BadRequestException('You can only withdraw your own offers');
        }
        await this.delete(id);
        return offer;
    }
};
exports.OffersService = OffersService;
exports.OffersService = OffersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], OffersService);
//# sourceMappingURL=offers.service.js.map