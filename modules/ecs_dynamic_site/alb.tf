resource "aws_lb" "public" {
  name               = "${var.project}-${var.env}-alb-dynamic"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_public_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-alb-dynamic"
  })
}

resource "aws_lb_target_group" "app" {
  name        = "${var.project}-${var.env}-tg-dynamic"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-tg-dynamic"
  })
}

# HTTP listener: redirect all traffic to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener: forward traffic to ECS target group
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.public.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = var.ssl_policy
  certificate_arn = aws_acm_certificate_validation.dynamic.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

