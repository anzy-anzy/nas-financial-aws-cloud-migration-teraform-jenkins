variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "static_fqdn" {
  type        = string
  description = "Static website FQDN, e.g. stop.anzyworld.com"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "primary_domain" {
  description = "Primary domain for the static site (e.g., stop.anzyworld.com)"
  type        = string
}

variable "alternate_domains" {
  description = "Additional domains that should also point to this CloudFront distribution (SANs/aliases)."
  type        = list(string)
  default     = []
}
