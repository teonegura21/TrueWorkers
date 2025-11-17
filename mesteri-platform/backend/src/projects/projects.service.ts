import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ConversationsService } from '../conversations/conversations.service';
import { Project, Milestone, Job, User, ProjectStatus } from '@prisma/client';
import { CreateProjectDto } from './dto/create-project.dto';

type ProjectWithRelations = Project & {
  job: Job | null;
  client: Pick<User, 'id' | 'fullName' | 'profileImage'> | null;
  craftsman: Pick<User, 'id' | 'fullName' | 'profileImage' | 'averageRating'> | null;
  milestoneRecords: Milestone[];
};

type ProjectWithMilestones = Project & { milestones: Milestone[] };

@Injectable()
export class ProjectsService {
  constructor(private prisma: PrismaService, private conversations: ConversationsService) {}

  private readonly projectInclude = {
    job: true,
    client: {
      select: { id: true, fullName: true, profileImage: true },
    },
    craftsman: {
      select: { id: true, fullName: true, profileImage: true, averageRating: true },
    },
    milestoneRecords: true,
  } as const;

  private mapProject(project: ProjectWithRelations) {
    const progressRatio = this.calculateProjectProgress({
      ...(project as any),
      milestones: project.milestoneRecords,
    } as ProjectWithMilestones);

    const progressPercent = project.progressPercent ?? Math.round(progressRatio * 100);

    return {
      id: project.id,
      title: project.title,
      description: project.description,
      status: project.status,
      totalBudget: project.totalBudget,
      agreedPrice: project.agreedPrice,
      progressPercent,
      progressRatio,
      clientId: project.clientId,
      clientName: project.client?.fullName,
      clientProfileImage: project.client?.profileImage,
      craftsmanId: project.craftsmanId,
      craftsmanName: project.craftsman?.fullName,
      craftsmanProfileImage: project.craftsman?.profileImage,
      craftsmanRating: project.craftsman?.averageRating,
      jobId: project.jobId,
      jobTitle: project.job?.title,
      jobLocation: project.job?.location,
      jobCity: project.job?.city,
      jobCategory: project.job?.category,
      galleryUrls: project.galleryUrls ?? [],
      notes: project.notes,
      startDate: project.startDate,
      deadline: project.deadline,
      endDate: project.endDate,
      createdAt: project.createdAt,
      milestones: project.milestoneRecords?.map(m => ({
        id: m.id,
        title: m.title,
        description: m.description,
        status: m.status,
        dueDate: m.dueDate,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
      })) ?? [],
    };
  }

  private calculateProjectProgress(project: ProjectWithMilestones): number {
    if (!project.milestones || project.milestones.length === 0) {
      return 0;
    }
    const completedMilestones = project.milestones.filter(
      (m) => m.status === 'completed',
    ).length;
    return completedMilestones / project.milestones.length;
  }

  private async fetchProject(where: { id: string }) {
    const project = await this.prisma.project.findUnique({
      where,
      include: this.projectInclude,
    });

    if (!project) {
      throw new NotFoundException(`Project with ID ${where.id} not found`);
    }

    return project as ProjectWithRelations;
  }

  async findAll() {
    const projects = await this.prisma.project.findMany({
      orderBy: { createdAt: 'desc' },
      include: this.projectInclude,
    });

    return projects.map(project => this.mapProject(project as ProjectWithRelations));
  }

  async findOne(id: string) {
    const project = await this.fetchProject({ id });
    return this.mapProject(project);
  }

  async findByClientId(clientId: string) {
    const projects = await this.prisma.project.findMany({
      where: { clientId },
      orderBy: { createdAt: 'desc' },
      include: this.projectInclude,
    });
    return projects.map(project => this.mapProject(project as ProjectWithRelations));
  }

  async findByCraftsmanId(craftsmanId: string) {
    const projects = await this.prisma.project.findMany({
      where: { craftsmanId },
      orderBy: { createdAt: 'desc' },
      include: this.projectInclude,
    });
    return projects.map(project => this.mapProject(project as ProjectWithRelations));
  }

  async findByStatus(status: ProjectStatus) {
    const projects = await this.prisma.project.findMany({
      where: { status },
      orderBy: { createdAt: 'desc' },
      include: this.projectInclude,
    });
    return projects.map(project => this.mapProject(project as ProjectWithRelations));
  }

  async findByUserId(userId: string) {
    const projects = await this.prisma.project.findMany({
      where: { OR: [{ clientId: userId }, { craftsmanId: userId }] },
      orderBy: { createdAt: 'desc' },
      include: this.projectInclude,
    });
    return projects.map(project => this.mapProject(project as ProjectWithRelations));
  }

  async createFromOffer(offerId: string, clientId: string, createData: CreateProjectDto) {
    const offer = await this.prisma.offer.findUnique({
      where: { id: offerId },
      include: {
        job: true,
        craftsman: true,
      },
    });

    if (!offer) {
      throw new NotFoundException(`Offer with ID ${offerId} not found`);
    }

    if (!offer.job || offer.job.clientId !== clientId) {
      throw new BadRequestException('You can only create projects from your own job offers');
    }

    const existingProject = await this.prisma.project.findFirst({
      where: { jobId: offer.job.id },
    });

    if (existingProject) {
      throw new BadRequestException('A project already exists for this offer');
    }

    const project = await this.prisma.project.create({
      data: {
        jobId: offer.job.id,
        clientId,
        craftsmanId: offer.craftsmanId,
        title: offer.job.title,
        description: offer.job.description,
        agreedPrice: offer.bidAmount,
        totalBudget: offer.job.budgetMax,
        status: ProjectStatus.ACTIVE,
        startDate: new Date(),
        progressPercent: 0,
        notes: createData.notes,
        deadline: createData.deadline ? new Date(createData.deadline) : undefined,
        galleryUrls: [],
      },
      include: this.projectInclude,
    });

    const conversation = await this.conversations.ensureProjectConversation(project.id, clientId);
    if (conversation && !project.primaryConversationId) {
      await this.prisma.project.update({
        where: { id: project.id },
        data: { primaryConversationId: conversation.id },
      });
    }

    const projectWithConversation = conversation && !project.primaryConversationId
      ? { ...(project as ProjectWithRelations), primaryConversationId: conversation.id }
      : (project as ProjectWithRelations);
    return this.mapProject(projectWithConversation);
  }

  async update(id: string, updateData: any) {
    const project = await this.prisma.project.update({
      where: { id },
      data: { ...updateData, updatedAt: new Date() },
      include: this.projectInclude,
    });

    return this.mapProject(project as ProjectWithRelations);
  }

  async complete(id: string) {
    const project = await this.prisma.project.update({
      where: { id },
      data: {
        status: ProjectStatus.COMPLETED,
        endDate: new Date(),
        progressPercent: 100,
      },
      include: this.projectInclude,
    });

    return this.mapProject(project as ProjectWithRelations);
  }

  async cancel(id: string) {
    const project = await this.prisma.project.update({
      where: { id },
      data: {
        status: ProjectStatus.CANCELLED,
        endDate: new Date(),
      },
      include: this.projectInclude,
    });

    return this.mapProject(project as ProjectWithRelations);
  }

  async getMilestones(projectId: string) {
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
      include: { milestoneRecords: true },
    });

    if (!project) {
      throw new NotFoundException(`Project with ID ${projectId} not found`);
    }

    return {
      projectId,
      milestones: project.milestoneRecords || [],
      totalCount: project.milestoneRecords ? project.milestoneRecords.length : 0,
    };
  }

  async addMilestone(projectId: string, milestoneData: any) {
    await this.fetchProject({ id: projectId });
    const newMilestone = await this.prisma.milestone.create({
      data: {
        projectId,
        ...milestoneData,
        status: milestoneData.status ?? 'pending',
      },
    });
    return {
      projectId,
      milestone: newMilestone,
      message: 'Milestone added successfully',
    };
  }

  async updateMilestone(projectId: string, milestoneId: string, updateData: any) {
    const milestone = await this.prisma.milestone.findUnique({ where: { id: milestoneId } });
    if (!milestone || milestone.projectId !== projectId) {
      throw new NotFoundException(`Milestone with ID ${milestoneId} not found on project ${projectId}`);
    }
    const updatedMilestone = await this.prisma.milestone.update({
      where: { id: milestoneId },
      data: updateData,
    });
    return {
      projectId,
      milestone: updatedMilestone,
      message: 'Milestone updated successfully',
    };
  }

  async completeMilestone(projectId: string, milestoneId: string) {
    const milestone = await this.prisma.milestone.findUnique({ where: { id: milestoneId } });
    if (!milestone || milestone.projectId !== projectId) {
      throw new NotFoundException(`Milestone with ID ${milestoneId} not found on project ${projectId}`);
    }
    const completedMilestone = await this.prisma.milestone.update({
      where: { id: milestoneId },
      data: { status: 'completed' },
    });
    return {
      projectId,
      milestone: completedMilestone,
      message: 'Milestone completed successfully',
    };
  }

  async getProgress(projectId: string) {
    const project = await this.fetchProject({ id: projectId });
    const progress = this.calculateProjectProgress({
      ...(project as any),
      milestones: project.milestoneRecords,
    } as ProjectWithMilestones);

    return {
      projectId,
      overallProgress: progress,
      status: project.status,
      isOverdue: project.deadline && new Date() > new Date(project.deadline),
    };
  }

  async validateProjectAccess(projectId: string, userId: string) {
    const project = await this.fetchProject({ id: projectId });
    return project.clientId === userId || project.craftsmanId === userId;
  }

  async getProjectOverview(clientId?: string, craftsmanId?: string) {
    const whereCondition: any = {};
    if (clientId) whereCondition.clientId = clientId;
    if (craftsmanId) whereCondition.craftsman = { id: craftsmanId };

    const projects = await this.prisma.project.findMany({
      where: whereCondition,
      include: { job: true, milestoneRecords: true },
      orderBy: { createdAt: 'desc' },
    });

    return {
      totalProjects: projects.length,
      activeProjects: projects.filter(p => p.status === ProjectStatus.ACTIVE).length,
      completedProjects: projects.filter(p => p.status === ProjectStatus.COMPLETED).length,
      cancelledProjects: projects.filter(p => p.status === ProjectStatus.CANCELLED).length,
      disputedProjects: projects.filter(p => p.status === ProjectStatus.DISPUTED).length,
    };
  }
}


