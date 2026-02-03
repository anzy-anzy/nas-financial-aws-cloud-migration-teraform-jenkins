output "cloudspace_engineers_role_arn" {
  value = module.iam.cloudspace_engineers_role_arn
}

output "nas_security_team_role_arn" {
  value = module.iam.nas_security_team_role_arn
}

output "nas_operations_team_role_arn" {
  value = module.iam.nas_operations_team_role_arn
}

output "n2g_auditing_role_arn" {
  value = module.iam.n2g_auditing_role_arn
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}
output "dynamic_alb_dns_name" {
  value = module.ecs_dynamic_site.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "rds_secret_arn" {
  value = module.rds.db_secret_arn
}

output "alerts_topic_arn" {
  value = module.rds.alerts_topic_arn
}
