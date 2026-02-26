# envs/prod/n2g_access_rules.tf

# Allow N2G VPC to reach NAS intranet via INTERNAL ALB (HTTP 80)
resource "aws_security_group_rule" "intranet_http_from_n2g" {
  type              = "ingress"
  security_group_id = module.network.sg_alb_internal_id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["172.31.0.0/16"]

  description = "Allow HTTP from N2G VPC via TGW"
}

# Allow N2G VPC to reach NAS RDS (MySQL 3306)
resource "aws_security_group_rule" "db_mysql_from_n2g" {
  type              = "ingress"
  security_group_id = module.network.sg_db_id

  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  cidr_blocks = ["172.31.0.0/16"]

  description = "Allow MySQL from N2G VPC via TGW"
}