# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project}-${var.env}"
  retention_in_days = var.cloudtrail_log_retention_days
  tags              = var.tags
}

# IAM role CloudTrail uses to write to CloudWatch Logs
resource "aws_iam_role" "cloudtrail_to_cw" {
  name = "${var.project}-${var.env}-cloudtrail-to-cw"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

# IAM policy allowing CloudTrail to put logs in the log group
resource "aws_iam_role_policy" "cloudtrail_to_cw" {
  name = "${var.project}-${var.env}-cloudtrail-to-cw-policy"
  role = aws_iam_role.cloudtrail_to_cw.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}
