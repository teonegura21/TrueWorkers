import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Put,
  Delete,
  HttpCode,
  HttpStatus,
  Query,
  Request,
} from '@nestjs/common';
import { ProjectsService } from './projects.service';
import { CreateMilestoneDto } from './dto/create-milestone.dto';
import { UpdateMilestoneDto } from './dto/update-milestone.dto';
import { CreateProjectDto } from './dto/create-project.dto';
import { UpdateProjectDto } from './dto/update-project.dto';

@Controller('projects')
export class ProjectsController {
  constructor(private readonly projectsService: ProjectsService) {}

  @Get()
  async findAll(@Query('userId') userId?: string) {
    if (userId) {
      return this.projectsService.findByUserId(userId);
    }
    return this.projectsService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.projectsService.findOne(id);
  }

  @Get('client/:clientId')
  async findByClientId(@Param('clientId') clientId: string) {
    return this.projectsService.findByClientId(clientId);
  }

  @Get('craftsman/:craftsmanId')
  async findByCraftsmanId(@Param('craftsmanId') craftsmanId: string) {
    return this.projectsService.findByCraftsmanId(craftsmanId);
  }

  @Post('from-offer/:offerId')
  async createFromOffer(@Param('offerId') offerId: string, @Body() createData: CreateProjectDto, @Request() req) {
    const clientId = req.user.id;
    return this.projectsService.createFromOffer(offerId, clientId, createData);
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() updateData: UpdateProjectDto) {
    return this.projectsService.update(id, updateData);
  }

  @Post(':id/complete')
  async complete(@Param('id') id: string) {
    return this.projectsService.complete(id);
  }

  @Post(':id/cancel')
  async cancel(@Param('id') id: string) {
    return this.projectsService.cancel(id);
  }

  @Get(':id/milestones')
  async getMilestones(@Param('id') id: string) {
    return this.projectsService.getMilestones(id);
  }

  @Post(':id/milestones')
  @HttpCode(HttpStatus.CREATED)
  async addMilestone(
    @Param('id') id: string,
    @Body() milestoneData: CreateMilestoneDto,
  ) {
    return this.projectsService.addMilestone(id, milestoneData);
  }

  @Put(':id/milestones/:milestoneId')
  async updateMilestone(
    @Param('id') id: string,
    @Param('milestoneId') milestoneId: string,
    @Body() updateData: UpdateMilestoneDto,
  ) {
    return this.projectsService.updateMilestone(id, milestoneId, updateData);
  }

  @Post(':id/milestones/:milestoneId/complete')
  async completeMilestone(
    @Param('id') id: string,
    @Param('milestoneId') milestoneId: string,
  ) {
    return this.projectsService.completeMilestone(id, milestoneId);
  }

  @Get(':id/progress')
  async getProgress(@Param('id') id: string) {
    return this.projectsService.getProgress(id);
  }
}
