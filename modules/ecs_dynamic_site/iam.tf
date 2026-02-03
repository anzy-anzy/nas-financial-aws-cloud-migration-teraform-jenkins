data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "${var.project}-${var.env}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-ecs-task-execution-role"
  })
}

resource "aws_iam_role_policy_attachment" "task_execution_policy" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role (used by the running application container)
resource "aws_iam_role" "task_role" {
  name               = "${var.project}-${var.env}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-ecs-task-role"
  })
}

data "aws_iam_policy_document" "secrets_read" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [var.db_secret_arn]
  }
}

resource "aws_iam_policy" "secrets_read" {
  name   = "${var.project}-${var.env}-ecs-secrets-read"
  policy = data.aws_iam_policy_document.secrets_read.json

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-ecs-secrets-read"
  })
}

resource "aws_iam_role_policy_attachment" "task_role_secrets" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.secrets_read.arn
}
