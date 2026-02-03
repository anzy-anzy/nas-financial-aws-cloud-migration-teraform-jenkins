provider "aws" {
  profile = "nas-prod"
  region  = "us-east-1"
}

# Explicit us-east-1 alias (used by CloudFront/ACM flows inside static_site module)
provider "aws" {
  alias   = "us_east_1"
  profile = "nas-prod"
  region  = "us-east-1"
}

# DR region provider (same NAS account)
provider "aws" {
  alias   = "dr"
  profile = "nas-prod"
  region  = "us-west-2"
}

# N2G account provider
provider "aws" {
  alias   = "n2g"
  profile = "n2g-audit"
  region  = "us-east-1"
}
