variable "project" { type = string }
variable "env"     { type = string }
variable "tags"    { type = map(string) }

# existing in your project already:
variable "alerts_topic_arn" { type = string }

# NEW for 8B
variable "cloudtrail_log_retention_days" {
  type    = number
  default = 90
}
