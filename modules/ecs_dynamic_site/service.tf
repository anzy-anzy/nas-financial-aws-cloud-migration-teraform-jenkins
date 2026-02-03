resource "aws_ecs_service" "this" {
  name            = "${var.project}-${var.env}-svc-dynamic"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.sg_app_dynamic_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = local.container_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.https]

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-svc-dynamic"
  })
}
