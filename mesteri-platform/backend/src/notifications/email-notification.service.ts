import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';
import { Transporter } from 'nodemailer';
import * as handlebars from 'handlebars';
import * as fs from 'fs';
import * as path from 'path';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationType } from './dto/update-notification-preference.dto';
import { NotificationChannel, NotificationStatus } from './push-notification.service';

export interface EmailResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

interface SMTPConfig {
  host: string;
  port: number;
  secure: boolean;
  auth: {
    user: string;
    pass: string;
  };
}

@Injectable()
export class EmailNotificationService implements OnModuleInit {
  private readonly logger = new Logger(EmailNotificationService.name);
  private transporter: Transporter;
  private templates: Map<string, handlebars.TemplateDelegate> = new Map();
  private readonly templatesDir: string;

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {
    this.templatesDir = path.join(
      __dirname,
      'templates',
    );
  }

  async onModuleInit() {
    await this.configureSMTP();
    await this.loadTemplates();
  }

  private async configureSMTP(): Promise<void> {
    try {
      const host = this.configService.get<string>('SMTP_HOST');
      const port = this.configService.get<number>('SMTP_PORT', 587);
      const secure =
        this.configService.get<string>('SMTP_SECURE', 'false') === 'true';
      const user = this.configService.get<string>('SMTP_USER');
      const pass = this.configService.get<string>('SMTP_PASS');

      if (!host || !user || !pass) {
        this.logger.warn(
          'SMTP configuration incomplete. Email notifications will be disabled.',
        );
        return;
      }

      const config: SMTPConfig = {
        host,
        port,
        secure,
        auth: {
          user,
          pass,
        },
      };

      this.transporter = nodemailer.createTransport(config);

      // Verify connection
      await this.transporter.verify();
      this.logger.log('SMTP connection verified successfully');
    } catch (error) {
      this.logger.error('Failed to configure SMTP', error.stack);
    }
  }

  private async loadTemplates(): Promise<void> {
    try {
      if (!fs.existsSync(this.templatesDir)) {
        this.logger.warn(
          `Templates directory not found: ${this.templatesDir}`,
        );
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
        } else {
          this.logger.warn(`Template file not found: ${templatePath}`);
        }
      }
    } catch (error) {
      this.logger.error('Failed to load email templates', error.stack);
    }
  }

  private renderTemplate(templateName: string, data: Record<string, unknown>): string {
    const template = this.templates.get(templateName);
    if (!template) {
      this.logger.error(`Template not found: ${templateName}`);
      // Fallback to plain text
      return `<html><body><h1>${(data.title as string) || 'Notification'}</h1><p>${(data.message as string) || JSON.stringify(data)}</p></body></html>`;
    }

    try {
      return template(data);
    } catch (error) {
      this.logger.error(
        `Error rendering template ${templateName}`,
        error.stack,
      );
      // Fallback to plain text
      return `<html><body><h1>${(data.title as string) || 'Notification'}</h1><p>${(data.message as string) || JSON.stringify(data)}</p></body></html>`;
    }
  }

  private async sendEmail(
    to: string,
    subject: string,
    html: string,
    attachments?: Array<{ filename?: string; content?: string | Buffer; path?: string; contentType?: string }>,
  ): Promise<EmailResult> {
    if (!this.transporter) {
      return {
        success: false,
        error: 'SMTP not configured',
      };
    }

    try {
      const fromEmail =
        this.configService.get<string>('FROM_EMAIL') || 'no-reply@mesteri.ro';
      const fromName =
        this.configService.get<string>('FROM_NAME') || 'Mesteri Platform';

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
    } catch (error) {
      this.logger.error(`Failed to send email to ${to}`, error.stack);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  async sendWelcomeEmail(user: {
    email: string;
    fullName: string;
    role: string;
  }): Promise<EmailResult> {
    const html = this.renderTemplate('welcome', {
      fullName: user.fullName,
      email: user.email,
      role: user.role === 'CRAFTSMAN' ? 'Meșter' : 'Client',
      accountCreatedDate: new Date().toLocaleDateString('ro-RO'),
      loginUrl: 'https://mesteri.ro/login',
      supportEmail: 'support@mesteri.ro',
    });

    const result = await this.sendEmail(
      user.email,
      'Bun venit la Mesteri Platform!',
      html,
    );

    // Log notification
    await this.logNotification({
      userId: user.email, // Use email as fallback
      type: NotificationType.WELCOME,
      channel: NotificationChannel.EMAIL,
      status: result.success
        ? NotificationStatus.SENT
        : NotificationStatus.FAILED,
      title: 'Bun venit la Mesteri Platform!',
      metadata: { email: user.email },
      errorMessage: result.error,
    });

    return result;
  }

  async sendContractNotification(
    user: { email: string; fullName: string },
    contract: {
      contractId: string;
      projectTitle: string;
      amount: number;
      clientName: string;
      craftsmanName: string;
    },
    action: 'created' | 'signed',
    pdfBuffer?: Buffer,
  ): Promise<EmailResult> {
    const templateName =
      action === 'created' ? 'contract-created' : 'contract-signed';
    const subject =
      action === 'created' ? 'Contract nou creat' : 'Contract semnat';

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
      type: NotificationType.CONTRACT_SIGNED,
      channel: NotificationChannel.EMAIL,
      status: result.success
        ? NotificationStatus.SENT
        : NotificationStatus.FAILED,
      title: subject,
      metadata: { contractId: contract.contractId },
      errorMessage: result.error,
    });

    return result;
  }

  async sendPaymentConfirmation(
    user: { email: string; fullName: string },
    payment: {
      transactionId: string;
      amount: number;
      projectTitle: string;
    },
  ): Promise<EmailResult> {
    const html = this.renderTemplate('payment-confirmation', {
      fullName: user.fullName,
      transactionId: payment.transactionId,
      amount: payment.amount.toFixed(2),
      recipientName: user.fullName,
      projectTitle: payment.projectTitle,
      paymentDate: new Date().toLocaleDateString('ro-RO'),
      viewPaymentUrl: `https://mesteri.ro/payments/${payment.transactionId}`,
    });

    const result = await this.sendEmail(
      user.email,
      'Confirmare plată - Mesteri Platform',
      html,
    );

    await this.logNotification({
      userId: user.email,
      type: NotificationType.PAYMENT_RECEIVED,
      channel: NotificationChannel.EMAIL,
      status: result.success
        ? NotificationStatus.SENT
        : NotificationStatus.FAILED,
      title: 'Confirmare plată',
      metadata: { transactionId: payment.transactionId },
      errorMessage: result.error,
    });

    return result;
  }

  async sendOfferNotification(
    client: { email: string; fullName: string },
    offer: {
      offerId: string;
      offerAmount: number;
      craftsmanName: string;
      estimatedDays: number;
      offerNotes?: string;
      jobTitle: string;
    },
  ): Promise<EmailResult> {
    const html = this.renderTemplate('offer-submitted', {
      fullName: client.fullName,
      offerAmount: offer.offerAmount.toFixed(2),
      craftsmanName: offer.craftsmanName,
      estimatedDays: offer.estimatedDays,
      offerNotes: offer.offerNotes || 'Fără note suplimentare',
      jobTitle: offer.jobTitle,
      viewOfferUrl: `https://mesteri.ro/offers/${offer.offerId}`,
    });

    const result = await this.sendEmail(
      client.email,
      'Ofertă nouă primită - Mesteri Platform',
      html,
    );

    await this.logNotification({
      userId: client.email,
      type: NotificationType.OFFER_SUBMITTED,
      channel: NotificationChannel.EMAIL,
      status: result.success
        ? NotificationStatus.SENT
        : NotificationStatus.FAILED,
      title: 'Ofertă nouă primită',
      metadata: { offerId: offer.offerId },
      errorMessage: result.error,
    });

    return result;
  }

  async sendJobCompletionEmail(
    users: Array<{ email: string; fullName: string }>,
    project: {
      projectId: string;
      projectTitle: string;
      completionDate: Date;
      finalAmount: number;
    },
  ): Promise<EmailResult[]> {
    const results: EmailResult[] = [];

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

      const result = await this.sendEmail(
        user.email,
        'Proiect finalizat - Mesteri Platform',
        html,
      );

      results.push(result);

      await this.logNotification({
        userId: user.email,
        type: NotificationType.PROJECT_COMPLETED,
        channel: NotificationChannel.EMAIL,
        status: result.success
          ? NotificationStatus.SENT
          : NotificationStatus.FAILED,
        title: 'Proiect finalizat',
        metadata: { projectId: project.projectId },
        errorMessage: result.error,
      });
    }

    return results;
  }

  private async logNotification(data: {
    userId: string;
    type: NotificationType;
    channel: NotificationChannel;
    status: NotificationStatus;
    title?: string;
    metadata?: Record<string, unknown>;
    errorMessage?: string;
  }): Promise<void> {
    try {
      await this.prisma.notificationLog.create({
        data: {
          ...data,
          sentAt: new Date(),
        },
      });
    } catch (error) {
      this.logger.error('Error logging email notification', error.stack);
    }
  }
}
