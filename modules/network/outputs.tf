output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "sg_alb_public_id" {
  value = aws_security_group.alb_public.id
}

output "sg_app_dynamic_id" {
  value = aws_security_group.app_dynamic.id
}

output "sg_db_id" {
  value = aws_security_group.db.id
}

output "sg_alb_internal_id" {
  value = aws_security_group.alb_internal.id
}
