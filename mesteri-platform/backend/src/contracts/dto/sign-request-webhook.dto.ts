class SignRequestSigner {
  email: string;
  signed_on: string; // ISO 8601 datetime
}

class SignRequestDocument {
  uuid: string;
  name: string;
}

export class SignRequestWebhookDto {
  event_type: 'signed' | 'declined' | 'cancelled' | 'sent';
  event_time: number; // Unix timestamp
  event_hash: string; // HMAC-SHA256 signature for verification
  token_name?: string; // Name of the API token used
  document: SignRequestDocument;
  team?: { subdomain: string };
  signers?: SignRequestSigner[];
  file_from_base64?: string;
  download_url?: string;
}
