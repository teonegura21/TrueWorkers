# Storage Upload Workflow

## Endpoint
- POST /storage/signed-url
- Auth: Authorization: Bearer <token>

### Request Body
`json
{
  "fileName": "baie-before.jpg",
  "contentType": "image/jpeg",
  "entityType": "MESSAGE",
  "entityId": "<related-id>",
  "bucketHint": "optional-custom-bucket"
}
`

### Response
`json
{
  "attachmentId": "att_123",
  "uploadUrl": "https://storage.googleapis.com/...",
  "bucket": "mesteri-media-dev",
  "objectPath": "message/user123/2025-09-19T09-35-00-baie-before.jpg",
  "expiresAt": "2025-09-19T09:50:00.000Z"
}
`

## Client Flow
1. Request signed URL.
2. Upload file with PUT uploadUrl and the Content-Type provided in the request.
3. After upload, call the domain API (e.g., /conversations/messages) with the ttachmentId to bind the file.
4. Background workers will later validate attachments and update status from PENDING to ACTIVE.

## Environment Variables
- MEDIA_BUCKET_PREFIX – bucket prefix (defaults to mesteri-media).
- APPLICATION_ENV or NODE_ENV – appended to the bucket name for per-environment isolation.
- SIGNED_URL_TTL_MS – expiry for upload URLs (ms), default 900000 (15 minutes).
- GCS_SIGNED_URLS – set to disabled to turn the feature off in development.
- GOOGLE_APPLICATION_CREDENTIALS – path to the service account JSON for the Storage client.

## Infrastructure
- Terraform templates for buckets/KMS/IAM: infra/terraform.
- GKE CronJobs for lifecycle + retention tasks: infra/k8s/storage-cronjobs.yaml.
Ensure these resources are applied before exposing the endpoint in staging/production.
