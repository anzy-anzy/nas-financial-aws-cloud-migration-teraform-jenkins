variable "project" {
  type    = string
  default = "nas-financial"
}

variable "env" {
  type    = string
  default = "prod"
}

variable "primary_region" {
  type    = string
  default = "us-east-1"
}

variable "dr_region" {
  type    = string
  default = "us-west-2"
}

variable "nas_account_id" {
  type    = string
  default = "436083576844"
}

variable "n2g_account_id" {
  type    = string
  default = "370445361290"
}

variable "route53_zone_id" {
  type    = string
  default = "Z06049403PYBB5K85PB4V"
}

variable "dynamic_fqdn" {
  type    = string
  default = "app.anzyworld.com"
}

variable "static_fqdn" {
  type    = string
  default = "stop.anzyworld.com"
}

variable "jenkins_fqdn" {
  type    = string
  default = "jenkins.anzyworld.com"
}

variable "vpc_cidr" {
  description = "CIDR block for the NAS VPC"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "pii_bucket_name" {
  type        = string
  description = "Unique S3 bucket name for NAS customer PII files"
}

variable "pii_kms_alias_name" {
  type        = string
  description = "KMS alias (without alias/ prefix) for S3 encryption key"
  default     = "nas-pii-s3-key"
}