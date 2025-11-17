"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SignRequestWebhookDto = void 0;
class SignRequestSigner {
    email;
    signed_on;
}
class SignRequestDocument {
    uuid;
    name;
}
class SignRequestWebhookDto {
    event_type;
    event_time;
    event_hash;
    token_name;
    document;
    team;
    signers;
    file_from_base64;
    download_url;
}
exports.SignRequestWebhookDto = SignRequestWebhookDto;
//# sourceMappingURL=sign-request-webhook.dto.js.map