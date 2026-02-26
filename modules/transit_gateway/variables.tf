variable "project" { type = string }
variable "env"     { type = string }
variable "tags"    { type = map(string) }

variable "nas_vpc_id" {
  description = "NAS VPC ID"
  type        = string
}

variable "nas_private_subnet_ids" {
  description = "NAS private subnet IDs for TGW attachment"
  type        = list(string)
}

variable "nas_private_route_table_id" {
  description = "NAS private route table ID to add route to N2G"
  type        = string
}

variable "n2g_account_id" {
  description = "N2G AWS account ID"
  type        = string
}

variable "n2g_vpc_cidr" {
  description = "N2G VPC CIDR (e.g., 172.31.0.0/16)"
  type        = string
}