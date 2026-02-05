variable "project" { type = string }
variable "env"     { type = string }
variable "tags"    { type = map(string) }

variable "limit_usd" {
  type    = number
  default = 30
}

variable "alert_emails" {
  type = list(string)
}
