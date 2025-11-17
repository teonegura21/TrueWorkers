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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var SignRequestService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.SignRequestService = void 0;
const common_1 = require("@nestjs/common");
const axios_1 = __importDefault(require("axios"));
let SignRequestService = SignRequestService_1 = class SignRequestService {
    logger = new common_1.Logger(SignRequestService_1.name);
    axiosInstance;
    SIGNREQUEST_API_URL = process.env.SIGNREQUEST_API_URL || 'https://api.signrequest.com/v1';
    SIGNREQUEST_API_TOKEN = process.env.SIGNREQUEST_API_TOKEN;
    constructor() {
        if (!this.SIGNREQUEST_API_TOKEN) {
            this.logger.warn('SIGNREQUEST_API_TOKEN is not defined. SignRequest features will not work.');
        }
        this.axiosInstance = axios_1.default.create({
            baseURL: this.SIGNREQUEST_API_URL,
            headers: {
                Authorization: `Token ${this.SIGNREQUEST_API_TOKEN}`,
                'Content-Type': 'application/json',
            },
            timeout: 30000,
        });
        this.axiosInstance.interceptors.response.use(response => {
            this.logger.debug(`SignRequest API Success: ${response.config.method?.toUpperCase()} ${response.config.url}`);
            return response;
        }, error => {
            this.logger.error(`SignRequest API Error: ${error.message}`, error.stack);
            if (error.response) {
                this.logger.error(`Response Data: ${JSON.stringify(error.response.data)}`);
                this.logger.error(`Response Status: ${error.response.status}`);
                throw new common_1.InternalServerErrorException(`SignRequest API error: ${error.response.status} - ${JSON.stringify(error.response.data)}`);
            }
            else if (error.request) {
                this.logger.error('No response received from SignRequest API.');
                throw new common_1.InternalServerErrorException('No response received from SignRequest API.');
            }
            else {
                this.logger.error('Error setting up SignRequest API request.');
                throw new common_1.InternalServerErrorException(`SignRequest API error: ${error.message}`);
            }
        });
    }
    async createDocumentWithSigners(htmlContent, documentName, signers) {
        if (!this.SIGNREQUEST_API_TOKEN) {
            throw new common_1.InternalServerErrorException('SignRequest is not configured. Please set SIGNREQUEST_API_TOKEN.');
        }
        this.logger.log(`Creating document "${documentName}" with ${signers.length} signers from HTML content.`);
        try {
            const htmlBase64 = Buffer.from(htmlContent, 'utf-8').toString('base64');
            this.logger.debug(`HTML content for "${documentName}" encoded (${htmlContent.length} chars).`);
            const fileName = documentName.endsWith('.html') ? documentName : `${documentName}.html`;
            const signRequestData = {
                file_from_content: htmlBase64,
                file_from_content_name: fileName,
                signers: signers.map(signer => ({
                    email: signer.email,
                    order: signer.order,
                    force_sign: signer.force_sign ?? true,
                })),
                subject: `Please sign: ${documentName}`,
                message: 'Please review and sign the attached document.',
                who: 'm',
                send_emails: true,
                send_reminders: true,
            };
            const response = await this.makeRequestWithRetry('post', '/signrequests/', signRequestData);
            this.logger.log(`SignRequest created successfully for "${documentName}". UUID: ${response.data.uuid}`);
            return response.data;
        }
        catch (error) {
            this.logger.error(`Failed to create document with signers from HTML: ${error.message}`, error.stack);
            throw new common_1.InternalServerErrorException('Failed to create document with signers from HTML.');
        }
    }
    async getDocumentStatus(documentUuid) {
        if (!this.SIGNREQUEST_API_TOKEN) {
            throw new common_1.InternalServerErrorException('SignRequest is not configured.');
        }
        try {
            this.logger.debug(`Fetching status for document: ${documentUuid}`);
            const response = await this.makeRequestWithRetry('get', `/signrequests/${documentUuid}/`);
            return response.data;
        }
        catch (error) {
            this.logger.error(`Failed to get document status: ${error.message}`, error.stack);
            throw new common_1.InternalServerErrorException('Failed to retrieve document status from SignRequest.');
        }
    }
    async downloadSignedPdf(pdfUrl) {
        try {
            this.logger.debug(`Downloading signed PDF from: ${pdfUrl}`);
            const response = await axios_1.default.get(pdfUrl, {
                responseType: 'arraybuffer',
                timeout: 60000,
            });
            this.logger.log(`Signed PDF downloaded successfully (${response.data.length} bytes).`);
            return Buffer.from(response.data);
        }
        catch (error) {
            this.logger.error(`Failed to download signed PDF: ${error.message}`, error.stack);
            throw new common_1.InternalServerErrorException('Failed to download signed PDF.');
        }
    }
    async makeRequestWithRetry(method, url, data, retries = 3, delay = 1000) {
        for (let i = 0; i < retries; i++) {
            try {
                this.logger.debug(`Attempt ${i + 1}/${retries}: ${method.toUpperCase()} ${url}`);
                const response = await this.axiosInstance({ method, url, data });
                return response;
            }
            catch (error) {
                const isLastAttempt = i === retries - 1;
                if (!isLastAttempt && this.shouldRetry(error)) {
                    this.logger.warn(`Request failed, retrying in ${delay / 1000}s... (${error.message})`);
                    await new Promise(resolve => setTimeout(resolve, delay));
                    delay *= 2;
                }
                else {
                    this.logger.error(`Final attempt failed: ${method.toUpperCase()} ${url}`, error.stack);
                    throw error;
                }
            }
        }
    }
    shouldRetry(error) {
        if (error.response) {
            const status = error.response.status;
            return status === 429 || (status >= 500 && status < 600);
        }
        return axios_1.default.isAxiosError(error) && !error.response;
    }
};
exports.SignRequestService = SignRequestService;
exports.SignRequestService = SignRequestService = SignRequestService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], SignRequestService);
//# sourceMappingURL=signrequest.service.js.map