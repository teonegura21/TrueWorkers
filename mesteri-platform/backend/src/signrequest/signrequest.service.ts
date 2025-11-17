import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
import axios, { AxiosInstance } from 'axios';

interface SignerInfo {
  email: string;
  order: number;
  force_sign?: boolean;
}

@Injectable()
export class SignRequestService {
  private readonly logger = new Logger(SignRequestService.name);
  private axiosInstance: AxiosInstance;
  private readonly SIGNREQUEST_API_URL = process.env.SIGNREQUEST_API_URL || 'https://api.signrequest.com/v1';
  private readonly SIGNREQUEST_API_TOKEN = process.env.SIGNREQUEST_API_TOKEN;

  constructor() {
    if (!this.SIGNREQUEST_API_TOKEN) {
      this.logger.warn('SIGNREQUEST_API_TOKEN is not defined. SignRequest features will not work.');
    }

    this.axiosInstance = axios.create({
      baseURL: this.SIGNREQUEST_API_URL,
      headers: {
        Authorization: `Token ${this.SIGNREQUEST_API_TOKEN}`,
        'Content-Type': 'application/json',
      },
      timeout: 30000, // 30 second timeout
    });

    // Intercept responses for logging and error handling
    this.axiosInstance.interceptors.response.use(
      response => {
        this.logger.debug(`SignRequest API Success: ${response.config.method?.toUpperCase()} ${response.config.url}`);
        return response;
      },
      error => {
        this.logger.error(`SignRequest API Error: ${error.message}`, error.stack);
        if (error.response) {
          this.logger.error(`Response Data: ${JSON.stringify(error.response.data)}`);
          this.logger.error(`Response Status: ${error.response.status}`);
          throw new InternalServerErrorException(
            `SignRequest API error: ${error.response.status} - ${JSON.stringify(error.response.data)}`
          );
        } else if (error.request) {
          this.logger.error('No response received from SignRequest API.');
          throw new InternalServerErrorException('No response received from SignRequest API.');
        } else {
          this.logger.error('Error setting up SignRequest API request.');
          throw new InternalServerErrorException(`SignRequest API error: ${error.message}`);
        }
      },
    );
  }

  /**
   * Creates a document from HTML content and sends it to SignRequest with specified signers.
   * SignRequest will convert the HTML to PDF and handle the signing process.
   *
   * @param htmlContent The HTML content for the document.
   * @param documentName The desired filename for the document (e.g., 'contract.html').
   * @param signers An array of signer objects with email and order (order=1 means simultaneous signing).
   * @returns The SignRequest document object with uuid, signing URLs, etc.
   */
  async createDocumentWithSigners(
    htmlContent: string,
    documentName: string,
    signers: SignerInfo[]
  ): Promise<any> {
    if (!this.SIGNREQUEST_API_TOKEN) {
      throw new InternalServerErrorException('SignRequest is not configured. Please set SIGNREQUEST_API_TOKEN.');
    }

    this.logger.log(`Creating document "${documentName}" with ${signers.length} signers from HTML content.`);

    try {
      // Convert HTML to base64
      const htmlBase64 = Buffer.from(htmlContent, 'utf-8').toString('base64');
      this.logger.debug(`HTML content for "${documentName}" encoded (${htmlContent.length} chars).`);

      // Ensure filename ends with .html for SignRequest to process it correctly
      const fileName = documentName.endsWith('.html') ? documentName : `${documentName}.html`;

      const signRequestData = {
        file_from_content: htmlBase64,
        file_from_content_name: fileName,
        signers: signers.map(signer => ({
          email: signer.email,
          order: signer.order, // order=1 for both = simultaneous signing
          force_sign: signer.force_sign ?? true,
        })),
        subject: `Please sign: ${documentName}`,
        message: 'Please review and sign the attached document.',
        who: 'm', // 'm' for me and others (sender + signers)
        send_emails: true,
        send_reminders: true,
      };

      const response = await this.makeRequestWithRetry('post', '/signrequests/', signRequestData);
      this.logger.log(`SignRequest created successfully for "${documentName}". UUID: ${response.data.uuid}`);

      return response.data;
    } catch (error) {
      this.logger.error(`Failed to create document with signers from HTML: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to create document with signers from HTML.');
    }
  }

  /**
   * Retrieves the status and details of a SignRequest document.
   *
   * @param documentUuid The UUID of the SignRequest document.
   * @returns The document details including status, signers, PDF URL, etc.
   */
  async getDocumentStatus(documentUuid: string): Promise<any> {
    if (!this.SIGNREQUEST_API_TOKEN) {
      throw new InternalServerErrorException('SignRequest is not configured.');
    }

    try {
      this.logger.debug(`Fetching status for document: ${documentUuid}`);
      const response = await this.makeRequestWithRetry('get', `/signrequests/${documentUuid}/`);
      return response.data;
    } catch (error) {
      this.logger.error(`Failed to get document status: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to retrieve document status from SignRequest.');
    }
  }

  /**
   * Downloads the signed PDF from SignRequest.
   *
   * @param pdfUrl The URL to the signed PDF provided by SignRequest.
   * @returns Buffer containing the PDF data.
   */
  async downloadSignedPdf(pdfUrl: string): Promise<Buffer> {
    try {
      this.logger.debug(`Downloading signed PDF from: ${pdfUrl}`);
      const response = await axios.get(pdfUrl, {
        responseType: 'arraybuffer',
        timeout: 60000, // 60 second timeout for large PDFs
      });

      this.logger.log(`Signed PDF downloaded successfully (${response.data.length} bytes).`);
      return Buffer.from(response.data);
    } catch (error) {
      this.logger.error(`Failed to download signed PDF: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to download signed PDF.');
    }
  }

  /**
   * Makes HTTP request with retry logic for transient failures.
   */
  private async makeRequestWithRetry(
    method: 'get' | 'post' | 'put' | 'delete',
    url: string,
    data?: any,
    retries = 3,
    delay = 1000,
  ): Promise<any> {
    for (let i = 0; i < retries; i++) {
      try {
        this.logger.debug(`Attempt ${i + 1}/${retries}: ${method.toUpperCase()} ${url}`);
        const response = await this.axiosInstance({ method, url, data });
        return response;
      } catch (error) {
        const isLastAttempt = i === retries - 1;

        if (!isLastAttempt && this.shouldRetry(error)) {
          this.logger.warn(`Request failed, retrying in ${delay / 1000}s... (${error.message})`);
          await new Promise(resolve => setTimeout(resolve, delay));
          delay *= 2; // Exponential backoff
        } else {
          this.logger.error(`Final attempt failed: ${method.toUpperCase()} ${url}`, error.stack);
          throw error;
        }
      }
    }
  }

  /**
   * Determines if a request should be retried based on error type.
   */
  private shouldRetry(error: any): boolean {
    if (error.response) {
      const status = error.response.status;
      // Retry on rate limiting or server errors
      return status === 429 || (status >= 500 && status < 600);
    }
    // Retry on network errors
    return axios.isAxiosError(error) && !error.response;
  }
}
