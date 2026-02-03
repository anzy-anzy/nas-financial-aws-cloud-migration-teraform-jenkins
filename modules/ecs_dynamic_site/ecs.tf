resource "aws_ecs_cluster" "this" {
  name = "${var.project}-${var.env}-ecs-cluster"

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-ecs-cluster"
  })
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project}-${var.env}-dynamic"
  retention_in_days = 14

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-cwlogs-dynamic"
  })
}
