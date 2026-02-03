terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [
        aws,
        aws.dr
      ]
    }

    random = {
      source = "hashicorp/random"
    }
  }
}
