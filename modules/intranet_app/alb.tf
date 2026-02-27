resource "aws_lb" "intranet_internal" {
  name               = "${var.project}-${var.env}-intra-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.alb_internal_sg_id]
  subnets            = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-alb-intranet-internal"
  })
}

resource "aws_lb_target_group" "intranet_tg" {
  name        = "${var.project}-${var.env}-tg-intranet"
  port        = var.http_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

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
    Name = "${var.project}-${var.env}-tg-intranet"
  })
}

resource "aws_lb_listener" "intranet_http" {
  load_balancer_arn = aws_lb.intranet_internal.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.intranet_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "intranet_attach" {
  target_group_arn = aws_lb_target_group.intranet_tg.arn
  target_id        = aws_instance.intranet.id
  port             = var.http_port
}