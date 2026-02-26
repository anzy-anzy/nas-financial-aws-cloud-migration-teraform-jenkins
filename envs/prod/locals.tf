locals {
  tags = {
    Project     = var.project
    Environment = var.env
    ManagedBy   = "Terraform"
    Name        = "${var.project}-${var.env}"
  }
}