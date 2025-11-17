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
var ContractsController_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.ContractsController = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const crypto_1 = require("crypto");
const contracts_service_1 = require("./contracts.service");
const sign_request_webhook_dto_1 = require("./dto/sign-request-webhook.dto");
const firebase_auth_guard_1 = require("../guards/firebase-auth.guard");
let ContractsController = ContractsController_1 = class ContractsController {
    contractsService;
    configService;
    logger = new common_1.Logger(ContractsController_1.name);
    constructor(contractsService, configService) {
        this.contractsService = contractsService;
        this.configService = configService;
    }
    async createContractForProject(projectId, req) {
        this.logger.log(`Request to create contract for project: ${projectId}`);
        const initiatorId = req.user.uid;
        return this.contractsService.createContract(projectId, initiatorId);
    }
    async getContract(contractId) {
        this.logger.log(`Fetching details for contract: ${contractId}`);
        return this.contractsService.getContractById(contractId);
    }
    async handleSignRequestWebhook(webhookDto) {
        this.logger.log(`SignRequest webhook received: ${webhookDto.event_type} for document ${webhookDto.document?.uuid}`);
        this.verifyWebhookSignature(webhookDto);
        if (webhookDto.event_type === 'signed') {
            await this.contractsService.handleSignedWebhook(webhookDto);
        }
        else if (webhookDto.event_type === 'declined') {
            await this.contractsService.handleDeclinedWebhook(webhookDto);
        }
        else if (webhookDto.event_type === 'cancelled') {
            await this.contractsService.handleCancelledWebhook(webhookDto);
        }
        else {
            this.logger.log(`Ignoring webhook event type: ${webhookDto.event_type}`);
        }
        return { success: true };
    }
    verifyWebhookSignature(webhookDto) {
        const apiToken = this.configService.get('SIGNREQUEST_API_TOKEN');
        if (!apiToken) {
            this.logger.error('SIGNREQUEST_API_TOKEN is not configured');
            throw new common_1.UnauthorizedException('Webhook verification failed: API token not configured');
        }
        const payload = `${webhookDto.event_time}${webhookDto.event_type}`;
        const expectedHash = (0, crypto_1.createHmac)('sha256', apiToken)
            .update(payload)
            .digest('hex');
        if (expectedHash !== webhookDto.event_hash) {
            this.logger.warn(`Webhook signature verification failed. Expected: ${expectedHash}, Received: ${webhookDto.event_hash}`);
            throw new common_1.UnauthorizedException('Invalid webhook signature');
        }
        this.logger.debug('Webhook signature verified successfully');
    }
};
exports.ContractsController = ContractsController;
__decorate([
    (0, common_1.Post)('/project/:projectId'),
    (0, common_1.UseGuards)(firebase_auth_guard_1.FirebaseAuthGuard),
    (0, common_1.HttpCode)(common_1.HttpStatus.CREATED),
    __param(0, (0, common_1.Param)('projectId')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ContractsController.prototype, "createContractForProject", null);
__decorate([
    (0, common_1.Get)(':contractId'),
    __param(0, (0, common_1.Param)('contractId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ContractsController.prototype, "getContract", null);
__decorate([
    (0, common_1.Post)('webhooks/signrequest'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    __param(0, (0, common_1.Body)(new common_1.ValidationPipe({ transform: true, whitelist: true }))),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [sign_request_webhook_dto_1.SignRequestWebhookDto]),
    __metadata("design:returntype", Promise)
], ContractsController.prototype, "handleSignRequestWebhook", null);
exports.ContractsController = ContractsController = ContractsController_1 = __decorate([
    (0, common_1.Controller)('contracts'),
    __metadata("design:paramtypes", [contracts_service_1.ContractsService,
        config_1.ConfigService])
], ContractsController);
//# sourceMappingURL=contracts.controller.js.map