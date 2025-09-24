terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  environments = ["dev", "staging", "prod"]
  bucket_name  = "${var.bucket_prefix}-${var.project_id}"
}

resource "google_kms_key_ring" "media" {
  name     = "media-artifacts"
  location = var.kms_location
}

resource "google_kms_crypto_key" "media" {
  name            = "media-default"
  key_ring        = google_kms_key_ring.media.id
  rotation_period = "2592000s"
}

resource "google_service_account" "storage_worker" {
  account_id   = "storage-worker"
  display_name = "Storage lifecycle worker"
}

resource "google_service_account" "signed_url_api" {
  account_id   = "signed-url-api"
  display_name = "Signed URL API"
}

resource "google_project_iam_member" "kms_encrypt" {
  project = var.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:${google_service_account.storage_worker.email}"
}

resource "google_storage_bucket" "media" {
  for_each                    = toset(local.environments)
  name                        = "${local.bucket_name}-${each.key}"
  location                    = var.bucket_location
  force_destroy               = false
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"

  encryption {
    default_kms_key_name = google_kms_crypto_key.media.id
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = var.lifecycle_active_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = var.lifecycle_archive_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_delete_days != null ? [1] : []
    content {
      condition {
        age = var.lifecycle_delete_days
      }
      action {
        type = "Delete"
      }
    }
  }

  labels = {
    application = "mesteri"
    environment = each.key
  }
}

resource "google_storage_bucket_iam_member" "signed_url_api" {
  for_each = google_storage_bucket.media
  bucket   = each.value.name
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.signed_url_api.email}"
}

output "bucket_names" {
  value = [for bucket in google_storage_bucket.media : bucket.name]
}
