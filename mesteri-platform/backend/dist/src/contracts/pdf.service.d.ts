export declare class PdfService {
    private readonly logger;
    private contractTemplate;
    constructor();
    private loadTemplate;
    generateContractPdf(contractData: any): Promise<Buffer>;
    generateSignatureOverlay(signatureData: string): Promise<Buffer>;
}
