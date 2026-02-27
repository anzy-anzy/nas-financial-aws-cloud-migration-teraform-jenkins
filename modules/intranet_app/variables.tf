variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

# Allow intranet access from inside VPC
variable "vpc_cidr" {
  type = string
}

# Optional: corporate CIDR (leave empty for now)
variable "corp_cidr" {
  type    = string
  default = ""
}

variable "route53_zone_id" {
  type = string
}

variable "intranet_fqdn" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "http_port" {
  type    = number
  default = 80
}
variable "ami_id" {
  type        = string
  description = "Optional AMI ID to pin intranet EC2."
  default     = ""
}

variable "vpn_client_cidr" {
  description = "Client VPN CIDR block (e.g. 10.200.0.0/22)"
  type        = string
  default     = ""
}

variable "alb_internal_sg_id" {
  type        = string
  description = "Security group ID for the internal ALB"
}