import { OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
export interface EmailResult {
    success: boolean;
    messageId?: string;
    error?: string;
}
export declare class EmailNotificationService implements OnModuleInit {
    private prisma;
    private configService;
    private readonly logger;
    private transporter;
    private templates;
    private readonly templatesDir;
    constructor(prisma: PrismaService, configService: ConfigService);
    onModuleInit(): Promise<void>;
    private configureSMTP;
    private loadTemplates;
    private renderTemplate;
    private sendEmail;
    sendWelcomeEmail(user: {
        email: string;
        fullName: string;
        role: string;
    }): Promise<EmailResult>;
    sendContractNotification(user: {
        email: string;
        fullName: string;
    }, contract: {
        contractId: string;
        projectTitle: string;
        amount: number;
        clientName: string;
        craftsmanName: string;
    }, action: 'created' | 'signed', pdfBuffer?: Buffer): Promise<EmailResult>;
    sendPaymentConfirmation(user: {
        email: string;
        fullName: string;
    }, payment: {
        transactionId: string;
        amount: number;
        projectTitle: string;
    }): Promise<EmailResult>;
    sendOfferNotification(client: {
        email: string;
        fullName: string;
    }, offer: {
        offerId: string;
        offerAmount: number;
        craftsmanName: string;
        estimatedDays: number;
        offerNotes?: string;
        jobTitle: string;
    }): Promise<EmailResult>;
    sendJobCompletionEmail(users: Array<{
        email: string;
        fullName: string;
    }>, project: {
        projectId: string;
        projectTitle: string;
        completionDate: Date;
        finalAmount: number;
    }): Promise<EmailResult[]>;
    private logNotification;
}
