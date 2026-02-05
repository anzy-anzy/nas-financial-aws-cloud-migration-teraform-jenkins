variable "project" { type = string }
variable "env"     { type = string }
variable "tags"    { type = map(string) }

# Prefer IAM Identity Center (AWS SSO) if you can.
variable "authentication_providers" {
  type    = list(string)
  default = ["AWS_SSO"]
}

variable "permission_type" {
  type    = string
  default = "SERVICE_MANAGED"
}
