declare class SignRequestSigner {
    email: string;
    signed_on: string;
}
declare class SignRequestDocument {
    uuid: string;
    name: string;
}
export declare class SignRequestWebhookDto {
    event_type: 'signed' | 'declined' | 'cancelled' | 'sent';
    event_time: number;
    event_hash: string;
    token_name?: string;
    document: SignRequestDocument;
    team?: {
        subdomain: string;
    };
    signers?: SignRequestSigner[];
    file_from_base64?: string;
    download_url?: string;
}
export {};
