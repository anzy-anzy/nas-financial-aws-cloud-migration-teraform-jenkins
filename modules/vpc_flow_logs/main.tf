data "aws_region" "current" {}

locals {
  name_prefix = "${var.project}-${var.env}"
  log_group   = "/vpc/flowlogs/${local.name_prefix}"
}

resource "aws_cloudwatch_log_group" "flowlogs" {
  name              = local.log_group
  retention_in_days = var.retention_in_days
  tags              = var.tags
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flowlogs" {
  name               = "${local.name_prefix}-vpc-flowlogs-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["${aws_cloudwatch_log_group.flowlogs.arn}:*"]
  }
}

resource "aws_iam_role_policy" "flowlogs" {
  name   = "${local.name_prefix}-vpc-flowlogs-policy"
  role   = aws_iam_role.flowlogs.id
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_flow_log" "vpc" {
  vpc_id               = var.vpc_id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flowlogs.arn
  iam_role_arn         = aws_iam_role.flowlogs.arn

  tags = merge(var.tags, { Name = "${local.name_prefix}-vpc-flowlogs" })
}
