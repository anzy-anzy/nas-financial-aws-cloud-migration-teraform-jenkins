resource "aws_securityhub_account" "this" {
  enable_default_standards = false
  auto_enable_controls     = true
}

# AWS Foundational Security Best Practices (latest)
resource "aws_securityhub_standards_subscription" "aws_foundations" {
  standards_arn = "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.this]
}

# CIS Benchmark (latest supported version)
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:us-east-1::standards/cis-aws-foundations-benchmark/v/1.4.0"
  depends_on    = [aws_securityhub_account.this]
}