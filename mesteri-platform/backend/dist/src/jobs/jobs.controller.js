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
exports.JobsController = void 0;
const common_1 = require("@nestjs/common");
const jobs_service_1 = require("./jobs.service");
const client_1 = require("@prisma/client");
const create_job_dto_1 = require("./dto/create-job.dto");
const search_jobs_dto_1 = require("./dto/search-jobs.dto");
const auth_decorators_1 = require("../decorators/auth.decorators");
let JobsController = class JobsController {
    jobsService;
    constructor(jobsService) {
        this.jobsService = jobsService;
    }
    findAll() {
        return this.jobsService.findAll();
    }
    findByClientId(clientId) {
        return this.jobsService.findByClientId(clientId);
    }
    findByCategory(category) {
        return this.jobsService.findByCategory(category);
    }
    findByStatus(status) {
        return this.jobsService.findByStatus(status);
    }
    async servicesOverview(categoryId, limit) {
        const parsedLimit = limit ? Number(limit) : undefined;
        const numericLimit = parsedLimit !== undefined && !Number.isNaN(parsedLimit) ? parsedLimit : undefined;
        return this.jobsService.getServicesOverview({
            categoryId,
            limit: numericLimit,
        });
    }
    create(jobData) {
        return this.jobsService.create(jobData);
    }
    update(id, updateData) {
        return this.jobsService.update(id, updateData);
    }
    delete(id) {
        return this.jobsService.delete(id);
    }
    marketingFeed(limit) {
        return this.jobsService.getMarketingFeed(limit);
    }
    async advancedSearch(searchDto) {
        return this.jobsService.advancedSearch(searchDto);
    }
    findOne(id) {
        return this.jobsService.findOne(id);
    }
};
exports.JobsController = JobsController;
__decorate([
    (0, auth_decorators_1.Public)(),
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], JobsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)('client/:clientId'),
    __param(0, (0, common_1.Param)('clientId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], JobsController.prototype, "findByClientId", null);
__decorate([
    (0, common_1.Get)('category/:category'),
    __param(0, (0, common_1.Param)('category')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], JobsController.prototype, "findByCategory", null);
__decorate([
    (0, common_1.Get)('status/:status'),
    __param(0, (0, common_1.Param)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], JobsController.prototype, "findByStatus", null);
__decorate([
    (0, common_1.Get)('services-overview'),
    __param(0, (0, common_1.Query)('categoryId')),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], JobsController.prototype, "servicesOverview", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_job_dto_1.CreateJobDto]),
    __metadata("design:returntype", void 0)
], JobsController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], JobsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], JobsController.prototype, "delete", null);
__decorate([
    (0, common_1.Get)('marketing/feed'),
    __param(0, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", void 0)
], JobsController.prototype, "marketingFeed", null);
__decorate([
    (0, auth_decorators_1.Public)(),
    (0, common_1.Get)('search'),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [search_jobs_dto_1.SearchJobsQueryDto]),
    __metadata("design:returntype", Promise)
], JobsController.prototype, "advancedSearch", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], JobsController.prototype, "findOne", null);
exports.JobsController = JobsController = __decorate([
    (0, common_1.Controller)('jobs'),
    __metadata("design:paramtypes", [jobs_service_1.JobsService])
], JobsController);
//# sourceMappingURL=jobs.controller.js.map