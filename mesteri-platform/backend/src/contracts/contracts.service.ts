import {
  Injectable,
  Logger,
  NotFoundException,
  InternalServerErrorException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SignRequestService } from '../signrequest/signrequest.service';
import { EmailNotificationService } from '../notifications/email-notification.service';
import { Contract, ContractStatus } from '@prisma/client';
import { Storage } from '@google-cloud/storage';
import * as handlebars from 'handlebars';
import * as fs from 'fs/promises';
import * as path from 'path';
import { SignRequestWebhookDto } from './dto/sign-request-webhook.dto';
import { ContractResponseDto } from './dto/contract-response.dto';
import { PdfService } from './pdf.service';

@Injectable()
export class ContractsService {
  private readonly logger = new Logger(ContractsService.name);
  private contractTemplate: handlebars.TemplateDelegate;
  private readonly storage: Storage;
  private readonly bucketName: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly signRequestService: SignRequestService,
    private readonly emailNotificationService: EmailNotificationService,
    private readonly pdfService: PdfService,
  ) {
    // Initialize Google Cloud Storage
    this.storage = new Storage();
    this.bucketName =
      process.env.GCS_CONTRACTS_BUCKET || 'mesteri-contracts-dev';
    this.loadTemplate();
  }

  private async loadTemplate() {
    try {
      const templatePath = path.join(__dirname, 'templates', 'contract.hbs');
      const templateString = await fs.readFile(templatePath, 'utf-8');
      this.contractTemplate = handlebars.compile(templateString);
      this.logger.log('Contract HTML template loaded successfully.');
    } catch (error) {
      this.logger.warn('Failed to load contract HTML template. Contract generation will be unavailable.', error.message);
      // Non-fatal: Contract feature will be unavailable but server can start
    }
  }

  async createContract(
    projectId: string,
    initiatorId: string,
  ): Promise<ContractResponseDto> {
    this.logger.log(
      `Starting contract creation for project ${projectId} by user ${initiatorId}`,
    );

    // Fetch project data with all relations
    const projectData = await this.fetchProjectData(projectId);

    // Generate PDF using Puppeteer
    const pdfBuffer = await this.pdfService.generateContractPdf({
      project: projectData,
      contract: { id: 'preview' }, // Placeholder for template
    });

    // Store PDF in GCS
    const gcsPath = await this.storePdfInGcs({ id: `temp-${projectId}`, projectId } as Contract, pdfBuffer);

    // Find default retention policy
    const retentionPolicy = await this.prisma.retentionPolicy.findUnique({
      where: { code: 'STANDARD_GUARANTEE' },
    });

    if (!retentionPolicy) {
      throw new InternalServerErrorException(
        'Retention policy not found. Please seed the database.',
      );
    }

    // Create contract record in database
    const contract = await this.prisma.contract.create({
      data: {
        projectId: projectId,
        status: ContractStatus.PENDING_SIGNATURE,
        version: 1,
        retentionPolicyId: retentionPolicy.id,
        storageObjectPath: gcsPath,
        hashSha256: null, // Could calculate hash here
      },
    });

    this.logger.log(`Contract ${contract.id} created and PDF stored in DB.`);

    // Generate signed URL for viewing
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

  async handleSignedWebhook(
    webhookDto: SignRequestWebhookDto,
  ): Promise<void> {
    const { document, download_url } = webhookDto;
    this.logger.log(
      `Processing 'signed' webhook for SignRequest document ${document.uuid}`,
    );

    if (!download_url) {
      this.logger.warn(
        `Webhook for ${document.uuid} is missing the download_url.`,
      );
      throw new BadRequestException('Webhook payload is missing required data.');
    }

    // Find contract by SignRequest document ID
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
      this.logger.error(
        `Received webhook for unknown SignRequest document ID: ${document.uuid}`,
      );
      throw new NotFoundException(
        `Contract with SignRequest ID ${document.uuid} not found.`,
      );
    }

    if (contract.status === ContractStatus.SIGNED) {
      this.logger.log(
        `Contract ${contract.id} already marked as signed. Ignoring webhook.`,
      );
      return;
    }

    try {
      // Download signed PDF (once)
      this.logger.log(
        `Downloading signed PDF for contract ${contract.id} from SignRequest.`,
      );
      const pdfBuffer = await this.signRequestService.downloadSignedPdf(download_url);

      // Store PDF in GCS
      const gcsPath = await this.storePdfInGcs(contract, pdfBuffer);

      // Update contract status
      await this.prisma.contract.update({
        where: { id: contract.id },
        data: {
          status: ContractStatus.SIGNED,
          signedAt: new Date(),
          clientSignedAt: new Date(), // Both signed simultaneously
          mesterSignedAt: new Date(),
          storageObjectPath: gcsPath,
          signRequestStatus: 'signed',
        },
      });

      this.logger.log(
        `Contract ${contract.id} successfully updated to SIGNED state.`,
      );

      // Send email notifications to both parties
      try {
        const contractDetails = {
          contractId: contract.id,
          projectTitle: contract.project.title,
          amount: contract.project.totalBudget || contract.project.agreedPrice || 0,
          clientName: contract.project.client.fullName,
          craftsmanName: contract.project.craftsman.fullName,
        };

        // Send to client
        await this.emailNotificationService.sendContractNotification(
          {
            email: contract.project.client.email,
            fullName: contract.project.client.fullName,
          },
          contractDetails,
          'signed',
          pdfBuffer,
        );

        // Send to craftsman
        await this.emailNotificationService.sendContractNotification(
          {
            email: contract.project.craftsman.email,
            fullName: contract.project.craftsman.fullName,
          },
          contractDetails,
          'signed',
          pdfBuffer,
        );

        this.logger.log(`Email notifications sent for contract ${contract.id}`);
      } catch (emailError) {
        // Log error but don't fail the webhook
        this.logger.error(
          `Failed to send email notifications for contract ${contract.id}`,
          emailError,
        );
      }

      // Note: Payment escrow is handled separately when project is created
      // Contract signing is legal formalization, not a payment trigger

    } catch (error) {
      this.logger.error(
        `Failed to process signed webhook for contract ${contract.id}`,
        error,
      );
      throw new InternalServerErrorException(
        'Failed to process and store signed contract.',
      );
    }
  }

  async handleDeclinedWebhook(
    webhookDto: SignRequestWebhookDto,
  ): Promise<void> {
    const { document } = webhookDto;
    this.logger.log(
      `Processing 'declined' webhook for SignRequest document ${document.uuid}`,
    );

    const contract = await this.prisma.contract.findUnique({
      where: { signRequestDocumentId: document.uuid },
    });

    if (!contract) {
      this.logger.error(
        `Received webhook for unknown SignRequest document ID: ${document.uuid}`,
      );
      throw new NotFoundException(
        `Contract with SignRequest ID ${document.uuid} not found.`,
      );
    }

    if (contract.status === ContractStatus.DECLINED) {
      this.logger.log(
        `Contract ${contract.id} already marked as declined. Ignoring webhook.`,
      );
      return;
    }

    await this.prisma.contract.update({
      where: { id: contract.id },
      data: {
        status: ContractStatus.DECLINED,
        signRequestStatus: 'declined',
      },
    });

    this.logger.log(`Contract ${contract.id} status updated to DECLINED.`);
    // TODO: Notify initiator that the contract was declined
  }

  async handleCancelledWebhook(
    webhookDto: SignRequestWebhookDto,
  ): Promise<void> {
    const { document } = webhookDto;
    this.logger.log(
      `Processing 'cancelled' webhook for SignRequest document ${document.uuid}`,
    );

    const contract = await this.prisma.contract.findUnique({
      where: { signRequestDocumentId: document.uuid },
    });

    if (!contract) {
      this.logger.error(
        `Received webhook for unknown SignRequest document ID: ${document.uuid}`,
      );
      throw new NotFoundException(
        `Contract with SignRequest ID ${document.uuid} not found.`,
      );
    }

    // Note: Using VOID status as per schema definition
    if (contract.status === ContractStatus.VOID) {
      this.logger.log(
        `Contract ${contract.id} already marked as void/cancelled. Ignoring webhook.`,
      );
      return;
    }

    await this.prisma.contract.update({
      where: { id: contract.id },
      data: {
        status: ContractStatus.VOID,
        signRequestStatus: 'cancelled',
      },
    });

    this.logger.log(`Contract ${contract.id} status updated to VOID.`);
  }

  async getContractById(contractId: string): Promise<ContractResponseDto> {
    const contract = await this.prisma.contract.findUnique({
      where: { id: contractId },
    });

    if (!contract) {
      throw new NotFoundException(`Contract with ID ${contractId} not found.`);
    }

    let signedDocumentUrl = null;
    if (
      contract.status === ContractStatus.SIGNED &&
      contract.storageObjectPath
    ) {
      // Generate 7-day signed URL
      signedDocumentUrl = await this.generateSignedUrl(
        contract.storageObjectPath,
        7,
      );
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

  private async fetchProjectData(projectId: string) {
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
      this.logger.warn(
        `Attempted to create contract for non-existent project: ${projectId}`,
      );
      throw new NotFoundException(`Project with ID ${projectId} not found.`);
    }

    return project;
  }

  private generateContractHtml(projectData: any): string {
    const templateData = {
      project: {
        ...projectData,
        // Format dates for Romanian display
        startDate: projectData.startDate?.toLocaleDateString('ro-RO') || 'N/A',
        deadline: projectData.deadline?.toLocaleDateString('ro-RO') || 'N/A',
      },
      currentDate: new Date().toLocaleDateString('ro-RO'),
    };
    return this.contractTemplate(templateData);
  }

  private async storePdfInGcs(
    contract: Contract,
    pdfBuffer: Buffer,
  ): Promise<string> {
    try {
      // Define GCS storage path
      const fileName = `contract-${contract.projectId}-${contract.id}.pdf`;
      const destinationPath = `contracts/${contract.projectId}/${fileName}`;

      this.logger.log(`Uploading signed PDF to GCS at: ${destinationPath}`);

      // Upload to Google Cloud Storage
      const bucket = this.storage.bucket(this.bucketName);
      const file = bucket.file(destinationPath);

      await file.save(pdfBuffer, {
        metadata: {
          contentType: 'application/pdf',
          cacheControl: 'public, max-age=31536000',
        },
      });

      this.logger.log(
        `Successfully uploaded signed PDF for contract ${contract.id}.`,
      );

      return destinationPath;
    } catch (error) {
      this.logger.error(
        `Failed to upload signed PDF for contract ${contract.id}`,
        error,
      );
      throw new InternalServerErrorException(
        'Failed to store signed PDF.',
      );
    }
  }

  private async generateSignedUrl(
    objectPath: string,
    daysValid: number = 7,
  ): Promise<string> {
    try {
      const bucket = this.storage.bucket(this.bucketName);
      const file = bucket.file(objectPath);

      const [url] = await file.getSignedUrl({
        version: 'v4',
        action: 'read',
        expires: Date.now() + daysValid * 24 * 60 * 60 * 1000,
      });

      return url;
    } catch (error) {
      this.logger.error(
        `Failed to generate signed URL for ${objectPath}`,
        error,
      );
      throw new InternalServerErrorException(
        'Failed to generate download URL.',
      );
    }
  }
}
