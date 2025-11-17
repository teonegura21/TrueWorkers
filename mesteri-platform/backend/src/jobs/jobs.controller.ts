import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
} from '@nestjs/common';
import { JobsService } from './jobs.service';
import { Job, JobCategory, JobStatus } from '@prisma/client';
import { CreateJobDto } from './dto/create-job.dto';
import { SearchJobsQueryDto } from './dto/search-jobs.dto';
import { Public } from '../decorators/auth.decorators';

@Controller('jobs')
export class JobsController {
  constructor(private readonly jobsService: JobsService) {}

  @Public()
  @Get()
  findAll() {
    return this.jobsService.findAll();
  }

  @Get('client/:clientId')
  findByClientId(@Param('clientId') clientId: string) {
    return this.jobsService.findByClientId(clientId);
  }

  @Get('category/:category')
  findByCategory(@Param('category') category: string) {
    return this.jobsService.findByCategory(category);
  }

  @Get('status/:status')
  findByStatus(@Param('status') status: JobStatus) {
    return this.jobsService.findByStatus(status);
  }

  @Get('services-overview')
  async servicesOverview(
    @Query('categoryId') categoryId?: string,
    @Query('limit') limit?: string,
  ) {
    const parsedLimit = limit ? Number(limit) : undefined;
    const numericLimit = parsedLimit !== undefined && !Number.isNaN(parsedLimit) ? parsedLimit : undefined;
    return this.jobsService.getServicesOverview({
      categoryId,
      limit: numericLimit,
    });
  }

  @Post()
  create(@Body() jobData: CreateJobDto) {
    return this.jobsService.create(jobData);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateData: Partial<Job>) {
    return this.jobsService.update(id, updateData);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.jobsService.delete(id);
  }

  @Get('marketing/feed')
  marketingFeed(@Query('limit') limit?: number) {
    return this.jobsService.getMarketingFeed(limit);
  }

  @Public()
  @Get('search')
  async advancedSearch(@Query() searchDto: SearchJobsQueryDto) {
    return this.jobsService.advancedSearch(searchDto);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.jobsService.findOne(id);
  }
}
