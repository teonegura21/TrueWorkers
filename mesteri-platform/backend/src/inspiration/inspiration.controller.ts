import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import { InspirationService } from './inspiration.service';
import type { CreateInspirationPostDto, UpdateInspirationPostDto } from './inspiration.service';
import { FirebaseAuthGuard } from '../guards/firebase-auth.guard';

@Controller('inspiration')
export class InspirationController {
  constructor(private readonly inspirationService: InspirationService) {}

  @Get('feed')
  async getFeed(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('userId') userId?: string,
  ) {
    const pageNum = page ? parseInt(page, 10) : 1;
    const limitNum = limit ? parseInt(limit, 10) : 20;
    return this.inspirationService.getFeed(userId, pageNum, limitNum);
  }

  @Get()
  async findAll(
    @Query('craftsmanId') craftsmanId?: string,
    @Query('city') city?: string,
    @Query('skill') skill?: string,
    @Query('isPromoted') isPromoted?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const filters = {
      craftsmanId,
      city,
      skill,
      isPromoted: isPromoted === 'true' ? true : undefined,
      page: page ? parseInt(page, 10) : 1,
      limit: limit ? parseInt(limit, 10) : 20,
    };
    return this.inspirationService.findAll(filters);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.inspirationService.findOne(id);
  }

  @Post()
  @UseGuards(FirebaseAuthGuard)
  async create(@Body() createDto: CreateInspirationPostDto) {
    return this.inspirationService.create(createDto);
  }

  @Put(':id')
  @UseGuards(FirebaseAuthGuard)
  async update(@Param('id') id: string, @Body() updateDto: UpdateInspirationPostDto) {
    return this.inspirationService.update(id, updateDto);
  }

  @Delete(':id')
  @UseGuards(FirebaseAuthGuard)
  async delete(@Param('id') id: string) {
    return this.inspirationService.delete(id);
  }

  @Post(':id/like')
  async like(@Param('id') id: string) {
    return this.inspirationService.incrementLikes(id);
  }

  @Post(':id/share')
  async share(@Param('id') id: string) {
    return this.inspirationService.incrementShares(id);
  }
}
