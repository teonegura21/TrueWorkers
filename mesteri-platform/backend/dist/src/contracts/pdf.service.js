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
var PdfService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.PdfService = void 0;
const common_1 = require("@nestjs/common");
const puppeteer = __importStar(require("puppeteer"));
const handlebars = __importStar(require("handlebars"));
const fs = __importStar(require("fs/promises"));
const path = __importStar(require("path"));
let PdfService = PdfService_1 = class PdfService {
    logger = new common_1.Logger(PdfService_1.name);
    contractTemplate;
    constructor() {
        this.loadTemplate();
    }
    async loadTemplate() {
        try {
            const templatePath = path.join(__dirname, '..', 'contracts', 'templates', 'contract.hbs');
            const templateString = await fs.readFile(templatePath, 'utf-8');
            this.contractTemplate = handlebars.compile(templateString);
            this.logger.log('PDF contract template loaded successfully.');
        }
        catch (error) {
            this.logger.warn('Failed to load PDF contract template. PDF generation will be unavailable.', error.message);
        }
    }
    async generateContractPdf(contractData) {
        if (!this.contractTemplate) {
            throw new common_1.InternalServerErrorException('PDF template not loaded. Cannot generate contract PDF.');
        }
        let browser;
        try {
            this.logger.log(`Generating PDF for contract ${contractData.contract?.id || 'unknown'}`);
            browser = await puppeteer.launch({
                headless: true,
                args: [
                    '--no-sandbox',
                    '--disable-setuid-sandbox',
                    '--disable-dev-shm-usage',
                    '--disable-accelerated-2d-canvas',
                    '--no-first-run',
                    '--no-zygote',
                    '--single-process',
                    '--disable-gpu'
                ]
            });
            const page = await browser.newPage();
            await page.setViewport({ width: 1200, height: 800 });
            const templateData = {
                project: {
                    ...contractData.project,
                    startDate: contractData.project?.startDate?.toLocaleDateString('ro-RO') || 'N/A',
                    deadline: contractData.project?.deadline?.toLocaleDateString('ro-RO') || 'N/A',
                },
                currentDate: new Date().toLocaleDateString('ro-RO'),
                contract: contractData.contract,
            };
            const htmlContent = this.contractTemplate(templateData);
            await page.setContent(htmlContent, {
                waitUntil: 'networkidle0',
                timeout: 30000
            });
            await page.waitForTimeout(1000);
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
        }
        catch (error) {
            this.logger.error('Failed to generate PDF', error);
            throw new common_1.InternalServerErrorException('Failed to generate contract PDF.');
        }
        finally {
            if (browser) {
                await browser.close();
            }
        }
    }
    async generateSignatureOverlay(signatureData) {
        let browser;
        try {
            browser = await puppeteer.launch({
                headless: true,
                args: ['--no-sandbox', '--disable-setuid-sandbox']
            });
            const page = await browser.newPage();
            await page.setViewport({ width: 400, height: 200 });
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
        }
        catch (error) {
            this.logger.error('Failed to generate signature overlay', error);
            throw new common_1.InternalServerErrorException('Failed to generate signature overlay.');
        }
        finally {
            if (browser) {
                await browser.close();
            }
        }
    }
};
exports.PdfService = PdfService;
exports.PdfService = PdfService = PdfService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], PdfService);
//# sourceMappingURL=pdf.service.js.map