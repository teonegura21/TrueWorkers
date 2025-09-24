# Terraform Bootstrap for Media Storage

This configuration provisions per-environment Google Cloud Storage buckets, KMS encryption keys, and service accounts required by the Mesteri platform media pipeline.

## Usage

```bash
cd infra/terraform
terraform init
terraform plan \
  -var "project_id=YOUR_GCP_PROJECT"
terraform apply \
  -var "project_id=YOUR_GCP_PROJECT"
```

Adjust `bucket_prefix`, lifecycle windows, and optional hard-delete thresholds as needed. The `storage-worker` service account is intended for the GKE CronJobs, while `signed-url-api` is used by the backend service issuing signed URLs.
