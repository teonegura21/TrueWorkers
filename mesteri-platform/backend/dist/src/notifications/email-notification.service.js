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
var EmailNotificationService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.EmailNotificationService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const nodemailer = __importStar(require("nodemailer"));
const handlebars = __importStar(require("handlebars"));
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const prisma_service_1 = require("../prisma/prisma.service");
const update_notification_preference_dto_1 = require("./dto/update-notification-preference.dto");
const push_notification_service_1 = require("./push-notification.service");
let EmailNotificationService = EmailNotificationService_1 = class EmailNotificationService {
    prisma;
    configService;
    logger = new common_1.Logger(EmailNotificationService_1.name);
    transporter;
    templates = new Map();
    templatesDir;
    constructor(prisma, configService) {
        this.prisma = prisma;
        this.configService = configService;
        this.templatesDir = path.join(__dirname, 'templates');
    }
    async onModuleInit() {
        await this.configureSMTP();
        await this.loadTemplates();
    }
    async configureSMTP() {
        try {
            const host = this.configService.get('SMTP_HOST');
            const port = this.configService.get('SMTP_PORT', 587);
            const secure = this.configService.get('SMTP_SECURE', 'false') === 'true';
            const user = this.configService.get('SMTP_USER');
            const pass = this.configService.get('SMTP_PASS');
            if (!host || !user || !pass) {
                this.logger.warn('SMTP configuration incomplete. Email notifications will be disabled.');
                return;
            }
            const config = {
                host,
                port,
                secure,
                auth: {
                    user,
                    pass,
                },
            };
            this.transporter = nodemailer.createTransport(config);
            await this.transporter.verify();
            this.logger.log('SMTP connection verified successfully');
        }
        catch (error) {
            this.logger.error('Failed to configure SMTP', error.stack);
        }
    }
    async loadTemplates() {
        try {
            if (!fs.existsSync(this.templatesDir)) {
                this.logger.warn(`Templates directory not found: ${this.templatesDir}`);
                return;
            }
            const templateFiles = [
                'welcome.hbs',
                'contract-created.hbs',
                'contract-signed.hbs',
                'payment-confirmation.hbs',
                'offer-submitted.hbs',
                'project-completed.hbs',
            ];
            for (const file of templateFiles) {
                const templatePath = path.join(this.templatesDir, file);
                if (fs.existsSync(templatePath)) {
                    const templateContent = fs.readFileSync(templatePath, 'utf-8');
                    const templateName = file.replace('.hbs', '');
                    this.templates.set(templateName, handlebars.compile(templateContent));
                    this.logger.log(`Loaded email template: ${templateName}`);
                }
                else {
                    this.logger.warn(`Template file not found: ${templatePath}`);
                }
            }
        }
        catch (error) {
            this.logger.error('Failed to load email templates', error.stack);
        }
    }
    renderTemplate(templateName, data) {
        const template = this.templates.get(templateName);
        if (!template) {
            this.logger.error(`Template not found: ${templateName}`);
            return `<html><body><h1>${data.title || 'Notification'}</h1><p>${data.message || JSON.stringify(data)}</p></body></html>`;
        }
        try {
            return template(data);
        }
        catch (error) {
            this.logger.error(`Error rendering template ${templateName}`, error.stack);
            return `<html><body><h1>${data.title || 'Notification'}</h1><p>${data.message || JSON.stringify(data)}</p></body></html>`;
        }
    }
    async sendEmail(to, subject, html, attachments) {
        if (!this.transporter) {
            return {
                success: false,
                error: 'SMTP not configured',
            };
        }
        try {
            const fromEmail = this.configService.get('FROM_EMAIL') || 'no-reply@mesteri.ro';
            const fromName = this.configService.get('FROM_NAME') || 'Mesteri Platform';
            const mailOptions = {
                from: `"${fromName}" <${fromEmail}>`,
                to,
                subject,
                html,
                attachments: attachments || [],
            };
            const info = await this.transporter.sendMail(mailOptions);
            this.logger.log(`Email sent to ${to}: ${info.messageId}`);
            return {
                success: true,
                messageId: info.messageId,
            };
        }
        catch (error) {
            this.logger.error(`Failed to send email to ${to}`, error.stack);
            return {
                success: false,
                error: error.message,
            };
        }
    }
    async sendWelcomeEmail(user) {
        const html = this.renderTemplate('welcome', {
            fullName: user.fullName,
            email: user.email,
            role: user.role === 'CRAFTSMAN' ? 'Meșter' : 'Client',
            accountCreatedDate: new Date().toLocaleDateString('ro-RO'),
            loginUrl: 'https://mesteri.ro/login',
            supportEmail: 'support@mesteri.ro',
        });
        const result = await this.sendEmail(user.email, 'Bun venit la Mesteri Platform!', html);
        await this.logNotification({
            userId: user.email,
            type: update_notification_preference_dto_1.NotificationType.WELCOME,
            channel: push_notification_service_1.NotificationChannel.EMAIL,
            status: result.success
                ? push_notification_service_1.NotificationStatus.SENT
                : push_notification_service_1.NotificationStatus.FAILED,
            title: 'Bun venit la Mesteri Platform!',
            metadata: { email: user.email },
            errorMessage: result.error,
        });
        return result;
    }
    async sendContractNotification(user, contract, action, pdfBuffer) {
        const templateName = action === 'created' ? 'contract-created' : 'contract-signed';
        const subject = action === 'created' ? 'Contract nou creat' : 'Contract semnat';
        const html = this.renderTemplate(templateName, {
            fullName: user.fullName,
            contractId: contract.contractId,
            projectTitle: contract.projectTitle,
            amount: contract.amount.toFixed(2),
            clientName: contract.clientName,
            craftsmanName: contract.craftsmanName,
            signedAt: new Date().toLocaleDateString('ro-RO'),
            viewContractUrl: `https://mesteri.ro/contracts/${contract.contractId}`,
        });
        const attachments = pdfBuffer
            ? [
                {
                    filename: `contract-${contract.contractId}.pdf`,
                    content: pdfBuffer,
                },
            ]
            : [];
        const result = await this.sendEmail(user.email, subject, html, attachments);
        await this.logNotification({
            userId: user.email,
            type: update_notification_preference_dto_1.NotificationType.CONTRACT_SIGNED,
            channel: push_notification_service_1.NotificationChannel.EMAIL,
            status: result.success
                ? push_notification_service_1.NotificationStatus.SENT
                : push_notification_service_1.NotificationStatus.FAILED,
            title: subject,
            metadata: { contractId: contract.contractId },
            errorMessage: result.error,
        });
        return result;
    }
    async sendPaymentConfirmation(user, payment) {
        const html = this.renderTemplate('payment-confirmation', {
            fullName: user.fullName,
            transactionId: payment.transactionId,
            amount: payment.amount.toFixed(2),
            recipientName: user.fullName,
            projectTitle: payment.projectTitle,
            paymentDate: new Date().toLocaleDateString('ro-RO'),
            viewPaymentUrl: `https://mesteri.ro/payments/${payment.transactionId}`,
        });
        const result = await this.sendEmail(user.email, 'Confirmare plată - Mesteri Platform', html);
        await this.logNotification({
            userId: user.email,
            type: update_notification_preference_dto_1.NotificationType.PAYMENT_RECEIVED,
            channel: push_notification_service_1.NotificationChannel.EMAIL,
            status: result.success
                ? push_notification_service_1.NotificationStatus.SENT
                : push_notification_service_1.NotificationStatus.FAILED,
            title: 'Confirmare plată',
            metadata: { transactionId: payment.transactionId },
            errorMessage: result.error,
        });
        return result;
    }
    async sendOfferNotification(client, offer) {
        const html = this.renderTemplate('offer-submitted', {
            fullName: client.fullName,
            offerAmount: offer.offerAmount.toFixed(2),
            craftsmanName: offer.craftsmanName,
            estimatedDays: offer.estimatedDays,
            offerNotes: offer.offerNotes || 'Fără note suplimentare',
            jobTitle: offer.jobTitle,
            viewOfferUrl: `https://mesteri.ro/offers/${offer.offerId}`,
        });
        const result = await this.sendEmail(client.email, 'Ofertă nouă primită - Mesteri Platform', html);
        await this.logNotification({
            userId: client.email,
            type: update_notification_preference_dto_1.NotificationType.OFFER_SUBMITTED,
            channel: push_notification_service_1.NotificationChannel.EMAIL,
            status: result.success
                ? push_notification_service_1.NotificationStatus.SENT
                : push_notification_service_1.NotificationStatus.FAILED,
            title: 'Ofertă nouă primită',
            metadata: { offerId: offer.offerId },
            errorMessage: result.error,
        });
        return result;
    }
    async sendJobCompletionEmail(users, project) {
        const results = [];
        for (const user of users) {
            const html = this.renderTemplate('project-completed', {
                fullName: user.fullName,
                projectTitle: project.projectTitle,
                completionDate: project.completionDate.toLocaleDateString('ro-RO'),
                finalAmount: project.finalAmount.toFixed(2),
                nextSteps: 'Vă rugăm să evaluați experiența colaborării.',
                viewProjectUrl: `https://mesteri.ro/projects/${project.projectId}`,
                reviewUrl: `https://mesteri.ro/projects/${project.projectId}/review`,
            });
            const result = await this.sendEmail(user.email, 'Proiect finalizat - Mesteri Platform', html);
            results.push(result);
            await this.logNotification({
                userId: user.email,
                type: update_notification_preference_dto_1.NotificationType.PROJECT_COMPLETED,
                channel: push_notification_service_1.NotificationChannel.EMAIL,
                status: result.success
                    ? push_notification_service_1.NotificationStatus.SENT
                    : push_notification_service_1.NotificationStatus.FAILED,
                title: 'Proiect finalizat',
                metadata: { projectId: project.projectId },
                errorMessage: result.error,
            });
        }
        return results;
    }
    async logNotification(data) {
        try {
            await this.prisma.notificationLog.create({
                data: {
                    ...data,
                    sentAt: new Date(),
                },
            });
        }
        catch (error) {
            this.logger.error('Error logging email notification', error.stack);
        }
    }
};
exports.EmailNotificationService = EmailNotificationService;
exports.EmailNotificationService = EmailNotificationService = EmailNotificationService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        config_1.ConfigService])
], EmailNotificationService);
//# sourceMappingURL=email-notification.service.js.map