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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProjectsController = void 0;
const common_1 = require("@nestjs/common");
const projects_service_1 = require("./projects.service");
const create_milestone_dto_1 = require("./dto/create-milestone.dto");
const update_milestone_dto_1 = require("./dto/update-milestone.dto");
const create_project_dto_1 = require("./dto/create-project.dto");
let ProjectsController = class ProjectsController {
    projectsService;
    constructor(projectsService) {
        this.projectsService = projectsService;
    }
    async findAll(userId) {
        if (userId) {
            return this.projectsService.findByUserId(userId);
        }
        return this.projectsService.findAll();
    }
    async findOne(id) {
        return this.projectsService.findOne(id);
    }
    async findByClientId(clientId) {
        return this.projectsService.findByClientId(clientId);
    }
    async findByCraftsmanId(craftsmanId) {
        return this.projectsService.findByCraftsmanId(craftsmanId);
    }
    async createFromOffer(offerId, createData, req) {
        const clientId = req.user.id;
        return this.projectsService.createFromOffer(offerId, clientId, createData);
    }
    async update(id, updateData) {
        return this.projectsService.update(id, updateData);
    }
    async complete(id) {
        return this.projectsService.complete(id);
    }
    async cancel(id) {
        return this.projectsService.cancel(id);
    }
    async getMilestones(id) {
        return this.projectsService.getMilestones(id);
    }
    async addMilestone(id, milestoneData) {
        return this.projectsService.addMilestone(id, milestoneData);
    }
    async updateMilestone(id, milestoneId, updateData) {
        return this.projectsService.updateMilestone(id, milestoneId, updateData);
    }
    async completeMilestone(id, milestoneId) {
        return this.projectsService.completeMilestone(id, milestoneId);
    }
    async getProgress(id) {
        return this.projectsService.getProgress(id);
    }
};
exports.ProjectsController = ProjectsController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Get)('client/:clientId'),
    __param(0, (0, common_1.Param)('clientId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "findByClientId", null);
__decorate([
    (0, common_1.Get)('craftsman/:craftsmanId'),
    __param(0, (0, common_1.Param)('craftsmanId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "findByCraftsmanId", null);
__decorate([
    (0, common_1.Post)('from-offer/:offerId'),
    __param(0, (0, common_1.Param)('offerId')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, create_project_dto_1.CreateProjectDto, Object]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "createFromOffer", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "update", null);
__decorate([
    (0, common_1.Post)(':id/complete'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "complete", null);
__decorate([
    (0, common_1.Post)(':id/cancel'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "cancel", null);
__decorate([
    (0, common_1.Get)(':id/milestones'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "getMilestones", null);
__decorate([
    (0, common_1.Post)(':id/milestones'),
    (0, common_1.HttpCode)(common_1.HttpStatus.CREATED),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, create_milestone_dto_1.CreateMilestoneDto]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "addMilestone", null);
__decorate([
    (0, common_1.Put)(':id/milestones/:milestoneId'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Param)('milestoneId')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, update_milestone_dto_1.UpdateMilestoneDto]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "updateMilestone", null);
__decorate([
    (0, common_1.Post)(':id/milestones/:milestoneId/complete'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Param)('milestoneId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "completeMilestone", null);
__decorate([
    (0, common_1.Get)(':id/progress'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ProjectsController.prototype, "getProgress", null);
exports.ProjectsController = ProjectsController = __decorate([
    (0, common_1.Controller)('projects'),
    __metadata("design:paramtypes", [projects_service_1.ProjectsService])
], ProjectsController);
//# sourceMappingURL=projects.controller.js.map