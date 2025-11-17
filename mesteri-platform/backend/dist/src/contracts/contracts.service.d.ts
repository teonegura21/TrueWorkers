import { PrismaService } from '../prisma/prisma.service';
import { SignRequestService } from '../signrequest/signrequest.service';
import { EmailNotificationService } from '../notifications/email-notification.service';
import { SignRequestWebhookDto } from './dto/sign-request-webhook.dto';
import { ContractResponseDto } from './dto/contract-response.dto';
import { PdfService } from './pdf.service';
export declare class ContractsService {
    private readonly prisma;
    private readonly signRequestService;
    private readonly emailNotificationService;
    private readonly pdfService;
    private readonly logger;
    private contractTemplate;
    private readonly storage;
    private readonly bucketName;
    constructor(prisma: PrismaService, signRequestService: SignRequestService, emailNotificationService: EmailNotificationService, pdfService: PdfService);
    private loadTemplate;
    createContract(projectId: string, initiatorId: string): Promise<ContractResponseDto>;
    handleSignedWebhook(webhookDto: SignRequestWebhookDto): Promise<void>;
    handleDeclinedWebhook(webhookDto: SignRequestWebhookDto): Promise<void>;
    handleCancelledWebhook(webhookDto: SignRequestWebhookDto): Promise<void>;
    getContractById(contractId: string): Promise<ContractResponseDto>;
    private fetchProjectData;
    private generateContractHtml;
    private storePdfInGcs;
    private generateSignedUrl;
}
