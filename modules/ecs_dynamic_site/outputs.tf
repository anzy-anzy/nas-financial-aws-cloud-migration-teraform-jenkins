output "alb_dns_name" {
  value = aws_lb.public.dns_name
}

output "alb_arn" {
  value = aws_lb.public.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "alb_zone_id" {
  value = aws_lb.public.zone_id
}
