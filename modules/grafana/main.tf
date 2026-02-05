data "aws_region" "current" {}

resource "aws_iam_role" "grafana" {
  name = "${var.project}-${var.env}-grafana-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "grafana.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

# Read CloudWatch metrics + alarms
resource "aws_iam_role_policy" "grafana_cloudwatch_read" {
  name = "${var.project}-${var.env}-grafana-cloudwatch-read"
  role = aws_iam_role.grafana.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_grafana_workspace" "this" {
  name                     = "${var.project}-${var.env}-grafana"
  description              = "NAS Financial Observability (Managed Grafana)"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = var.authentication_providers
  permission_type          = var.permission_type
  data_sources             = ["CLOUDWATCH"]
  role_arn                 = aws_iam_role.grafana.arn

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-grafana"
  })
}
