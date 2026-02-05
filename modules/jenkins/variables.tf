variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
  description = "PRIVATE subnet id recommended"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
