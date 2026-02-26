variable "project" { type = string }
variable "env"     { type = string }

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_cidr" {
  type = string
}

variable "client_cidr_block" {
  description = "CIDR assigned to VPN clients (must NOT overlap with VPC CIDR)"
  type        = string
  default     = "10.200.0.0/22"
}

variable "server_certificate_arn" {
  type = string
}

variable "client_root_certificate_arn" {
  type = string
}


variable "tags" {
  type    = map(string)
  default = {}
}
