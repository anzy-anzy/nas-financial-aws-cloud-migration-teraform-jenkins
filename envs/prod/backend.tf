terraform {
  backend "s3" {
    bucket         = "nas-financial-tfstate-436083576844"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "nas-financial-tflock"
    encrypt        = true
  }
}
