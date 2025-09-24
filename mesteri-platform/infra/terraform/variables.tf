variable "project_id" {
  description = "GCP project identifier"
  type        = string
}

variable "region" {
  description = "Default region for resources"
  type        = string
  default     = "europe-west4"
}

variable "kms_location" {
  description = "Location for KMS key ring"
  type        = string
  default     = "europe"
}

variable "bucket_location" {
  description = "Location for GCS buckets"
  type        = string
  default     = "europe-west4"
}

variable "bucket_prefix" {
  description = "Prefix for storage bucket names"
  type        = string
  default     = "mesteri-media"
}

variable "lifecycle_active_days" {
  description = "Days to keep in Standard storage before transitioning to Nearline"
  type        = number
  default     = 180
}

variable "lifecycle_archive_days" {
  description = "Days to keep in Nearline before transitioning to Archive"
  type        = number
  default     = 1080
}

variable "lifecycle_delete_days" {
  description = "Optional hard-delete after X days (null to disable)"
  type        = number
  default     = null
}
