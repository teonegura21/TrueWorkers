import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Request,
  HttpStatus,
  HttpCode,
  Query,
} from '@nestjs/common';
import { OffersService } from './offers.service';
import { CreateOfferDto, UpdateOfferDto } from './offers.dtos';

@Controller('offers')
export class OffersController {
  constructor(private readonly offersService: OffersService) {}

  @Get()
  async findAll() {
    return this.offersService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.offersService.findOne(id);
  }

  @Get('job/:jobId')
  async findByJobId(@Param('jobId') jobId: string) {
    return this.offersService.findByJobId(jobId);
  }

  @Get('craftsman/:craftsmanId')
  async findByCraftsmanId(@Param('craftsmanId') craftsmanId: string) {
    return this.offersService.findByCraftsmanId(craftsmanId);
  }

  @Post()
  async create(@Body() offerData: CreateOfferDto, @Request() req: any) {
    return this.offersService.create({
      ...offerData,
      craftsmanId: req.user.userId, // Add current user as craftsman
    });
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() updateData: UpdateOfferDto) {
    return this.offersService.update(id, updateData);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async delete(@Param('id') id: string) {
    await this.offersService.delete(id);
  }

  @Post(':id/accept')
  async acceptOffer(@Param('id') id: string) {
    return this.offersService.acceptOffer(id);
  }

  @Post(':id/reject')
  async rejectOffer(@Param('id') id: string) {
    return this.offersService.rejectOffer(id);
  }

  @Post(':id/withdraw')
  async withdrawOffer(@Param('id') id: string, @Request() req: any) {
    return this.offersService.withdrawOffer(id, req.user.userId);
  }

  @Get('job/:jobId/stats')
  async getOfferStats(@Param('jobId') jobId: string) {
    return this.offersService.getOfferStats(jobId);
  }
}
