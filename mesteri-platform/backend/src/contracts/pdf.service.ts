import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
import * as puppeteer from 'puppeteer';
import * as handlebars from 'handlebars';
import * as fs from 'fs/promises';
import * as path from 'path';

@Injectable()
export class PdfService {
  private readonly logger = new Logger(PdfService.name);
  private contractTemplate: handlebars.TemplateDelegate;

  constructor() {
    this.loadTemplate();
  }

  private async loadTemplate() {
    try {
      const templatePath = path.join(__dirname, '..', 'contracts', 'templates', 'contract.hbs');
      const templateString = await fs.readFile(templatePath, 'utf-8');
      this.contractTemplate = handlebars.compile(templateString);
      this.logger.log('PDF contract template loaded successfully.');
    } catch (error) {
      this.logger.warn('Failed to load PDF contract template. PDF generation will be unavailable.', error.message);
      // Non-fatal: PDF feature will be unavailable but server can start
    }
  }

  /**
   * Generate PDF from contract data using Puppeteer and Handlebars template
   * @param contractData - The contract and project data
   * @returns Buffer containing the PDF data
   */
  async generateContractPdf(contractData: any): Promise<Buffer> {
    if (!this.contractTemplate) {
      throw new InternalServerErrorException('PDF template not loaded. Cannot generate contract PDF.');
    }

    let browser;
    try {
      this.logger.log(`Generating PDF for contract ${contractData.contract?.id || 'unknown'}`);

      // Launch Puppeteer browser
      browser = await puppeteer.launch({
        headless: true,
        args: [
          '--no-sandbox',
          '--disable-setuid-sandbox',
          '--disable-dev-shm-usage',
          '--disable-accelerated-2d-canvas',
          '--no-first-run',
          '--no-zygote',
          '--single-process', // Helps with memory issues
          '--disable-gpu'
        ]
      });

      const page = await browser.newPage();

      // Set viewport for better PDF rendering
      await page.setViewport({ width: 1200, height: 800 });

      // Prepare template data
      const templateData = {
        project: {
          ...contractData.project,
          // Format dates for Romanian display
          startDate: contractData.project?.startDate?.toLocaleDateString('ro-RO') || 'N/A',
          deadline: contractData.project?.deadline?.toLocaleDateString('ro-RO') || 'N/A',
        },
        currentDate: new Date().toLocaleDateString('ro-RO'),
        contract: contractData.contract,
      };

      // Generate HTML content
      const htmlContent = this.contractTemplate(templateData);

      // Set HTML content
      await page.setContent(htmlContent, {
        waitUntil: 'networkidle0',
        timeout: 30000
      });

      // Wait for any dynamic content to load
      await page.waitForTimeout(1000);

      // Generate PDF
      const pdfBuffer = await page.pdf({
        format: 'A4',
        printBackground: true,
        margin: {
          top: '20mm',
          right: '15mm',
          bottom: '20mm',
          left: '15mm'
        },
        preferCSSPageSize: false,
        displayHeaderFooter: false,
      });

      this.logger.log(`PDF generated successfully (${pdfBuffer.length} bytes)`);

      return pdfBuffer;

    } catch (error) {
      this.logger.error('Failed to generate PDF', error);
      throw new InternalServerErrorException('Failed to generate contract PDF.');
    } finally {
      if (browser) {
        await browser.close();
      }
    }
  }

  /**
   * Generate a simple signature overlay PDF for embedding signatures
   * @param signatureData - Base64 encoded signature image
   * @returns Buffer containing the signature overlay PDF
   */
  async generateSignatureOverlay(signatureData: string): Promise<Buffer> {
    let browser;
    try {
      browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
      });

      const page = await browser.newPage();
      await page.setViewport({ width: 400, height: 200 });

      // Create simple HTML with signature image
      const html = `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { margin: 0; padding: 20px; }
            .signature { max-width: 100%; max-height: 100%; }
          </style>
        </head>
        <body>
          <img src="data:image/png;base64,${signatureData}" class="signature" />
        </body>
        </html>
      `;

      await page.setContent(html);
      const pdfBuffer = await page.pdf({
        width: '300px',
        height: '150px',
        printBackground: true,
        margin: { top: 0, right: 0, bottom: 0, left: 0 }
      });

      return pdfBuffer;

    } catch (error) {
      this.logger.error('Failed to generate signature overlay', error);
      throw new InternalServerErrorException('Failed to generate signature overlay.');
    } finally {
      if (browser) {
        await browser.close();
      }
    }
  }
}