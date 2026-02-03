variable "project" { type = string }
variable "env"     { type = string }

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# Provide exactly 2 AZs (e.g., ["us-east-1a","us-east-1b"])
variable "azs" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
