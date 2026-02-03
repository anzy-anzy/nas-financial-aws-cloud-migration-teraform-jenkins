variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "nas_account_id" {
  type = string
}

variable "n2g_account_id" {
  type = string
}

# Who can assume the internal NAS roles (CloudSpace/Security/Ops)?
# Best practice: restrict to specific principal ARNs (your admin user/role).
# For a project, you can allow the whole NAS account root.
variable "trusted_nas_principals" {
  type        = list(string)
  description = "List of AWS principal ARNs allowed to assume NAS internal roles."
  default     = []
}

# Optional: ExternalId for N2G assume-role (recommended in real life)
variable "n2g_external_id" {
  type        = string
  description = "Optional external ID for N2G assume role."
  default     = ""
}
