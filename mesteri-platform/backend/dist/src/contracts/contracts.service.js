"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var ContractsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.ContractsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const signrequest_service_1 = require("../signrequest/signrequest.service");
const email_notification_service_1 = require("../notifications/email-notification.service");
const client_1 = require("@prisma/client");
const storage_1 = require("@google-cloud/storage");
const handlebars = __importStar(require("handlebars"));
const fs = __importStar(require("fs/promises"));
const path = __importStar(require("path"));
const pdf_service_1 = require("./pdf.service");
let ContractsService = ContractsService_1 = class ContractsService {
    prisma;
    signRequestService;
    emailNotificationService;
    pdfService;
    logger = new common_1.Logger(ContractsService_1.name);
    contractTemplate;
    storage;
    bucketName;
    constructor(prisma, signRequestService, emailNotificationService, pdfService) {
        this.prisma = prisma;
        this.signRequestService = signRequestService;
        this.emailNotificationService = emailNotificationService;
        this.pdfService = pdfService;
        this.storage = new storage_1.Storage();
        this.bucketName =
            process.env.GCS_CONTRACTS_BUCKET || 'mesteri-contracts-dev';
        this.loadTemplate();
    }
    async loadTemplate() {
        try {
            const templatePath = path.join(__dirname, 'templates', 'contract.hbs');
            const templateString = await fs.readFile(templatePath, 'utf-8');
            this.contractTemplate = handlebars.compile(templateString);
            this.logger.log('Contract HTML template loaded successfully.');
        }
        catch (error) {
            this.logger.warn('Failed to load contract HTML template. Contract generation will be unavailable.', error.message);
        }
    }
    async createContract(projectId, initiatorId) {
        this.logger.log(`Starting contract creation for project ${projectId} by user ${initiatorId}`);
        const projectData = await this.fetchProjectData(projectId);
        const pdfBuffer = await this.pdfService.generateContractPdf({
            project: projectData,
            contract: { id: 'preview' },
        });
        const gcsPath = await this.storePdfInGcs({ id: `temp-${projectId}`, projectId }, pdfBuffer);
        const retentionPolicy = await this.prisma.retentionPolicy.findUnique({
            where: { code: 'STANDARD_GUARANTEE' },
        });
        if (!retentionPolicy) {
            throw new common_1.InternalServerErrorException('Retention policy not found. Please seed the database.');
        }
        const contract = await this.prisma.contract.create({
            data: {
                projectId: projectId,
                status: client_1.ContractStatus.PENDING_SIGNATURE,
                version: 1,
                retentionPolicyId: retentionPolicy.id,
                storageObjectPath: gcsPath,
                hashSha256: null,
            },
        });
        this.logger.log(`Contract ${contract.id} created and PDF stored in DB.`);
        const signedUrl = await this.generateSignedUrl(gcsPath, 7);
        return {
            id: contract.id,
            projectId: contract.projectId,
            status: contract.status,
            version: contract.version,
            signedDocumentUrl: signedUrl,
            createdAt: contract.createdAt,
        };
    }
    async handleSignedWebhook(webhookDto) {
        const { document, download_url } = webhookDto;
        this.logger.log(`Processing 'signed' webhook for SignRequest document ${document.uuid}`);
        if (!download_url) {
            this.logger.warn(`Webhook for ${document.uuid} is missing the download_url.`);
            throw new common_1.BadRequestException('Webhook payload is missing required data.');
        }
        const contract = await this.prisma.contract.findUnique({
            where: { signRequestDocumentId: document.uuid },
            include: {
                project: {
                    include: {
                        client: true,
                        craftsman: true,
                    },
                },
            },
        });
        if (!contract) {
            this.logger.error(`Received webhook for unknown SignRequest document ID: ${document.uuid}`);
            throw new common_1.NotFoundException(`Contract with SignRequest ID ${document.uuid} not found.`);
        }
        if (contract.status === client_1.ContractStatus.SIGNED) {
            this.logger.log(`Contract ${contract.id} already marked as signed. Ignoring webhook.`);
            return;
        }
        try {
            this.logger.log(`Downloading signed PDF for contract ${contract.id} from SignRequest.`);
            const pdfBuffer = await this.signRequestService.downloadSignedPdf(download_url);
            const gcsPath = await this.storePdfInGcs(contract, pdfBuffer);
            await this.prisma.contract.update({
                where: { id: contract.id },
                data: {
                    status: client_1.ContractStatus.SIGNED,
                    signedAt: new Date(),
                    clientSignedAt: new Date(),
                    mesterSignedAt: new Date(),
                    storageObjectPath: gcsPath,
                    signRequestStatus: 'signed',
                },
            });
            this.logger.log(`Contract ${contract.id} successfully updated to SIGNED state.`);
            try {
                const contractDetails = {
                    contractId: contract.id,
                    projectTitle: contract.project.title,
                    amount: contract.project.totalBudget || contract.project.agreedPrice || 0,
                    clientName: contract.project.client.fullName,
                    craftsmanName: contract.project.craftsman.fullName,
                };
                await this.emailNotificationService.sendContractNotification({
                    email: contract.project.client.email,
                    fullName: contract.project.client.fullName,
                }, contractDetails, 'signed', pdfBuffer);
                await this.emailNotificationService.sendContractNotification({
                    email: contract.project.craftsman.email,
                    fullName: contract.project.craftsman.fullName,
                }, contractDetails, 'signed', pdfBuffer);
                this.logger.log(`Email notifications sent for contract ${contract.id}`);
            }
            catch (emailError) {
                this.logger.error(`Failed to send email notifications for contract ${contract.id}`, emailError);
            }
        }
        catch (error) {
            this.logger.error(`Failed to process signed webhook for contract ${contract.id}`, error);
            throw new common_1.InternalServerErrorException('Failed to process and store signed contract.');
        }
    }
    async handleDeclinedWebhook(webhookDto) {
        const { document } = webhookDto;
        this.logger.log(`Processing 'declined' webhook for SignRequest document ${document.uuid}`);
        const contract = await this.prisma.contract.findUnique({
            where: { signRequestDocumentId: document.uuid },
        });
        if (!contract) {
            this.logger.error(`Received webhook for unknown SignRequest document ID: ${document.uuid}`);
            throw new common_1.NotFoundException(`Contract with SignRequest ID ${document.uuid} not found.`);
        }
        if (contract.status === client_1.ContractStatus.DECLINED) {
            this.logger.log(`Contract ${contract.id} already marked as declined. Ignoring webhook.`);
            return;
        }
        await this.prisma.contract.update({
            where: { id: contract.id },
            data: {
                status: client_1.ContractStatus.DECLINED,
                signRequestStatus: 'declined',
            },
        });
        this.logger.log(`Contract ${contract.id} status updated to DECLINED.`);
    }
    async handleCancelledWebhook(webhookDto) {
        const { document } = webhookDto;
        this.logger.log(`Processing 'cancelled' webhook for SignRequest document ${document.uuid}`);
        const contract = await this.prisma.contract.findUnique({
            where: { signRequestDocumentId: document.uuid },
        });
        if (!contract) {
            this.logger.error(`Received webhook for unknown SignRequest document ID: ${document.uuid}`);
            throw new common_1.NotFoundException(`Contract with SignRequest ID ${document.uuid} not found.`);
        }
        if (contract.status === client_1.ContractStatus.VOID) {
            this.logger.log(`Contract ${contract.id} already marked as void/cancelled. Ignoring webhook.`);
            return;
        }
        await this.prisma.contract.update({
            where: { id: contract.id },
            data: {
                status: client_1.ContractStatus.VOID,
                signRequestStatus: 'cancelled',
            },
        });
        this.logger.log(`Contract ${contract.id} status updated to VOID.`);
    }
    async getContractById(contractId) {
        const contract = await this.prisma.contract.findUnique({
            where: { id: contractId },
        });
        if (!contract) {
            throw new common_1.NotFoundException(`Contract with ID ${contractId} not found.`);
        }
        let signedDocumentUrl = null;
        if (contract.status === client_1.ContractStatus.SIGNED &&
            contract.storageObjectPath) {
            signedDocumentUrl = await this.generateSignedUrl(contract.storageObjectPath, 7);
        }
        return {
            id: contract.id,
            projectId: contract.projectId,
            status: contract.status,
            version: contract.version,
            signedDocumentUrl,
            createdAt: contract.createdAt,
        };
    }
    async fetchProjectData(projectId) {
        const project = await this.prisma.project.findUnique({
            where: { id: projectId },
            include: {
                client: true,
                craftsman: true,
                job: true,
                milestoneRecords: true,
            },
        });
        if (!project) {
            this.logger.warn(`Attempted to create contract for non-existent project: ${projectId}`);
            throw new common_1.NotFoundException(`Project with ID ${projectId} not found.`);
        }
        return project;
    }
    generateContractHtml(projectData) {
        const templateData = {
            project: {
                ...projectData,
                startDate: projectData.startDate?.toLocaleDateString('ro-RO') || 'N/A',
                deadline: projectData.deadline?.toLocaleDateString('ro-RO') || 'N/A',
            },
            currentDate: new Date().toLocaleDateString('ro-RO'),
        };
        return this.contractTemplate(templateData);
    }
    async storePdfInGcs(contract, pdfBuffer) {
        try {
            const fileName = `contract-${contract.projectId}-${contract.id}.pdf`;
            const destinationPath = `contracts/${contract.projectId}/${fileName}`;
            this.logger.log(`Uploading signed PDF to GCS at: ${destinationPath}`);
            const bucket = this.storage.bucket(this.bucketName);
            const file = bucket.file(destinationPath);
            await file.save(pdfBuffer, {
                metadata: {
                    contentType: 'application/pdf',
                    cacheControl: 'public, max-age=31536000',
                },
            });
            this.logger.log(`Successfully uploaded signed PDF for contract ${contract.id}.`);
            return destinationPath;
        }
        catch (error) {
            this.logger.error(`Failed to upload signed PDF for contract ${contract.id}`, error);
            throw new common_1.InternalServerErrorException('Failed to store signed PDF.');
        }
    }
    async generateSignedUrl(objectPath, daysValid = 7) {
        try {
            const bucket = this.storage.bucket(this.bucketName);
            const file = bucket.file(objectPath);
            const [url] = await file.getSignedUrl({
                version: 'v4',
                action: 'read',
                expires: Date.now() + daysValid * 24 * 60 * 60 * 1000,
            });
            return url;
        }
        catch (error) {
            this.logger.error(`Failed to generate signed URL for ${objectPath}`, error);
            throw new common_1.InternalServerErrorException('Failed to generate download URL.');
        }
    }
};
exports.ContractsService = ContractsService;
exports.ContractsService = ContractsService = ContractsService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        signrequest_service_1.SignRequestService,
        email_notification_service_1.EmailNotificationService,
        pdf_service_1.PdfService])
], ContractsService);
//# sourceMappingURL=contracts.service.js.map