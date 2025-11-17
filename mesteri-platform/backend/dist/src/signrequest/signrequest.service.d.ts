interface SignerInfo {
    email: string;
    order: number;
    force_sign?: boolean;
}
export declare class SignRequestService {
    private readonly logger;
    private axiosInstance;
    private readonly SIGNREQUEST_API_URL;
    private readonly SIGNREQUEST_API_TOKEN;
    constructor();
    createDocumentWithSigners(htmlContent: string, documentName: string, signers: SignerInfo[]): Promise<any>;
    getDocumentStatus(documentUuid: string): Promise<any>;
    downloadSignedPdf(pdfUrl: string): Promise<Buffer>;
    private makeRequestWithRetry;
    private shouldRetry;
}
export {};
