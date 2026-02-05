variable "project" { type = string }
variable "env"     { type = string }
variable "tags"    { type = map(string) }

variable "vpc_id" { type = string }

variable "retention_in_days" {
  type    = number
  default = 90
}
