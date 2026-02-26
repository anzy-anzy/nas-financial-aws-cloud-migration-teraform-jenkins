variable "bucket_name" {
  type        = string
  description = "Unique S3 bucket name (globally unique)"
}

variable "kms_alias_name" {
  type        = string
  description = "KMS alias name (without 'alias/' prefix)"
  default     = "nas-pii-s3-key"
}

variable "archive_after_days" {
  type        = number
  description = "Days before transitioning objects to archive storage"
  default     = 30
}

variable "archive_storage_class" {
  type        = string
  description = "Archive storage class: GLACIER, GLACIER_IR, or DEEP_ARCHIVE"
  default     = "GLACIER"
}

variable "expire_after_days" {
  type        = number
  description = "Days before object expiration (5 years ~ 1825 days)"
  default     = 1825
}