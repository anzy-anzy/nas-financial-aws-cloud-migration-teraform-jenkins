variable "project" { type = string }
variable "env"     { type = string }

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "sg_alb_public_id" {
  type = string
}

variable "sg_app_dynamic_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# App settings
variable "container_image" {
  type    = string
  default = "nginxdemos/hello:latest"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 hosted zone ID for the domain (e.g., anzyworld.com zone)."
}

variable "dynamic_fqdn" {
  type        = string
  description = "FQDN for the dynamic website (e.g., app.anzyworld.com)."
}

variable "ssl_policy" {
  type        = string
  description = "ALB TLS security policy."
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "db_secret_arn" {
  type        = string
  description = "Secrets Manager ARN containing DB credentials JSON {username,password}."
}

variable "db_host" {
  type        = string
  description = "RDS endpoint hostname."
}

variable "db_name" {
  type        = string
  default     = "nasdb"
}

