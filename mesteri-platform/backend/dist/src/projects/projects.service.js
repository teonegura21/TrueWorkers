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
exports.ProjectsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const conversations_service_1 = require("../conversations/conversations.service");
const client_1 = require("@prisma/client");
let ProjectsService = class ProjectsService {
    prisma;
    conversations;
    constructor(prisma, conversations) {
        this.prisma = prisma;
        this.conversations = conversations;
    }
    projectInclude = {
        job: true,
        client: {
            select: { id: true, fullName: true, profileImage: true },
        },
        craftsman: {
            select: { id: true, fullName: true, profileImage: true, averageRating: true },
        },
        milestoneRecords: true,
    };
    mapProject(project) {
        const progressRatio = this.calculateProjectProgress({
            ...project,
            milestones: project.milestoneRecords,
        });
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
    calculateProjectProgress(project) {
        if (!project.milestones || project.milestones.length === 0) {
            return 0;
        }
        const completedMilestones = project.milestones.filter((m) => m.status === 'completed').length;
        return completedMilestones / project.milestones.length;
    }
    async fetchProject(where) {
        const project = await this.prisma.project.findUnique({
            where,
            include: this.projectInclude,
        });
        if (!project) {
            throw new common_1.NotFoundException(`Project with ID ${where.id} not found`);
        }
        return project;
    }
    async findAll() {
        const projects = await this.prisma.project.findMany({
            orderBy: { createdAt: 'desc' },
            include: this.projectInclude,
        });
        return projects.map(project => this.mapProject(project));
    }
    async findOne(id) {
        const project = await this.fetchProject({ id });
        return this.mapProject(project);
    }
    async findByClientId(clientId) {
        const projects = await this.prisma.project.findMany({
            where: { clientId },
            orderBy: { createdAt: 'desc' },
            include: this.projectInclude,
        });
        return projects.map(project => this.mapProject(project));
    }
    async findByCraftsmanId(craftsmanId) {
        const projects = await this.prisma.project.findMany({
            where: { craftsmanId },
            orderBy: { createdAt: 'desc' },
            include: this.projectInclude,
        });
        return projects.map(project => this.mapProject(project));
    }
    async findByStatus(status) {
        const projects = await this.prisma.project.findMany({
            where: { status },
            orderBy: { createdAt: 'desc' },
            include: this.projectInclude,
        });
        return projects.map(project => this.mapProject(project));
    }
    async findByUserId(userId) {
        const projects = await this.prisma.project.findMany({
            where: { OR: [{ clientId: userId }, { craftsmanId: userId }] },
            orderBy: { createdAt: 'desc' },
            include: this.projectInclude,
        });
        return projects.map(project => this.mapProject(project));
    }
    async createFromOffer(offerId, clientId, createData) {
        const offer = await this.prisma.offer.findUnique({
            where: { id: offerId },
            include: {
                job: true,
                craftsman: true,
            },
        });
        if (!offer) {
            throw new common_1.NotFoundException(`Offer with ID ${offerId} not found`);
        }
        if (!offer.job || offer.job.clientId !== clientId) {
            throw new common_1.BadRequestException('You can only create projects from your own job offers');
        }
        const existingProject = await this.prisma.project.findFirst({
            where: { jobId: offer.job.id },
        });
        if (existingProject) {
            throw new common_1.BadRequestException('A project already exists for this offer');
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
                status: client_1.ProjectStatus.ACTIVE,
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
            ? { ...project, primaryConversationId: conversation.id }
            : project;
        return this.mapProject(projectWithConversation);
    }
    async update(id, updateData) {
        const project = await this.prisma.project.update({
            where: { id },
            data: { ...updateData, updatedAt: new Date() },
            include: this.projectInclude,
        });
        return this.mapProject(project);
    }
    async complete(id) {
        const project = await this.prisma.project.update({
            where: { id },
            data: {
                status: client_1.ProjectStatus.COMPLETED,
                endDate: new Date(),
                progressPercent: 100,
            },
            include: this.projectInclude,
        });
        return this.mapProject(project);
    }
    async cancel(id) {
        const project = await this.prisma.project.update({
            where: { id },
            data: {
                status: client_1.ProjectStatus.CANCELLED,
                endDate: new Date(),
            },
            include: this.projectInclude,
        });
        return this.mapProject(project);
    }
    async getMilestones(projectId) {
        const project = await this.prisma.project.findUnique({
            where: { id: projectId },
            include: { milestoneRecords: true },
        });
        if (!project) {
            throw new common_1.NotFoundException(`Project with ID ${projectId} not found`);
        }
        return {
            projectId,
            milestones: project.milestoneRecords || [],
            totalCount: project.milestoneRecords ? project.milestoneRecords.length : 0,
        };
    }
    async addMilestone(projectId, milestoneData) {
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
    async updateMilestone(projectId, milestoneId, updateData) {
        const milestone = await this.prisma.milestone.findUnique({ where: { id: milestoneId } });
        if (!milestone || milestone.projectId !== projectId) {
            throw new common_1.NotFoundException(`Milestone with ID ${milestoneId} not found on project ${projectId}`);
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
    async completeMilestone(projectId, milestoneId) {
        const milestone = await this.prisma.milestone.findUnique({ where: { id: milestoneId } });
        if (!milestone || milestone.projectId !== projectId) {
            throw new common_1.NotFoundException(`Milestone with ID ${milestoneId} not found on project ${projectId}`);
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
    async getProgress(projectId) {
        const project = await this.fetchProject({ id: projectId });
        const progress = this.calculateProjectProgress({
            ...project,
            milestones: project.milestoneRecords,
        });
        return {
            projectId,
            overallProgress: progress,
            status: project.status,
            isOverdue: project.deadline && new Date() > new Date(project.deadline),
        };
    }
    async validateProjectAccess(projectId, userId) {
        const project = await this.fetchProject({ id: projectId });
        return project.clientId === userId || project.craftsmanId === userId;
    }
    async getProjectOverview(clientId, craftsmanId) {
        const whereCondition = {};
        if (clientId)
            whereCondition.clientId = clientId;
        if (craftsmanId)
            whereCondition.craftsman = { id: craftsmanId };
        const projects = await this.prisma.project.findMany({
            where: whereCondition,
            include: { job: true, milestoneRecords: true },
            orderBy: { createdAt: 'desc' },
        });
        return {
            totalProjects: projects.length,
            activeProjects: projects.filter(p => p.status === client_1.ProjectStatus.ACTIVE).length,
            completedProjects: projects.filter(p => p.status === client_1.ProjectStatus.COMPLETED).length,
            cancelledProjects: projects.filter(p => p.status === client_1.ProjectStatus.CANCELLED).length,
            disputedProjects: projects.filter(p => p.status === client_1.ProjectStatus.DISPUTED).length,
        };
    }
};
exports.ProjectsService = ProjectsService;
exports.ProjectsService = ProjectsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService, conversations_service_1.ConversationsService])
], ProjectsService);
//# sourceMappingURL=projects.service.js.map