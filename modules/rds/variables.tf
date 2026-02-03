variable "project" { type = string }
variable "env"     { type = string }

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_sg_id" {
  type        = string
  description = "Security group ID for RDS (should only allow from app SG)."
}

variable "db_name" {
  type    = string
  default = "nasdb"
}

variable "db_username" {
  type    = string
  default = "nasadmin"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "alarm_email" {
  type        = string
  description = "Email address to subscribe to SNS alerts."
}

variable "tags" {
  type    = map(string)
  default = {}
}
