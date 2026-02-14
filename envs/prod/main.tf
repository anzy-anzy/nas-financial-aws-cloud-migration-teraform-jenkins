locals {
  tags = {
    Project     = var.project
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}

module "iam" {
  source = "../../modules/iam"

  project        = var.project
  env            = var.env
  nas_account_id = var.nas_account_id
  n2g_account_id = var.n2g_account_id

  # For a project, leaving this empty allows NAS account root to assume roles.
  # If you want to lock it down, add your admin IAM user ARN here.
  trusted_nas_principals = []
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source = "../../modules/network"

  project  = var.project
  env      = var.env
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = local.tags
}

module "rds" {
  source = "../../modules/rds"

  # IMPORTANT: this enables cross-region resources inside the module
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  project = var.project
  env     = var.env

  private_subnet_ids = module.network.private_subnet_ids
  db_sg_id           = module.network.sg_db_id

  db_name     = "nasdb"
  db_username = "nasadmin"

  multi_az              = true
  backup_retention_days = 7

  alarm_email = "anselmebsiy59@gmail.com"

  tags = local.tags
}

module "ecs_dynamic_site" {
  source = "../../modules/ecs_dynamic_site"

  project = var.project
  env     = var.env

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  sg_alb_public_id  = module.network.sg_alb_public_id
  sg_app_dynamic_id = module.network.sg_app_dynamic_id

  route53_zone_id = var.route53_zone_id
  dynamic_fqdn    = var.dynamic_fqdn

  # Phase 6A inputs (ECS can read Secrets Manager + knows RDS endpoint)
  db_host       = module.rds.db_endpoint
  db_secret_arn = module.rds.db_secret_arn
  db_name       = "nasdb"

  tags = local.tags

  # Option A (fast demo app)
  container_image = "nginxdemos/hello:latest"
  container_port  = 80

  desired_count = 2
  cpu           = 256
  memory        = 512
}

module "static_site" {
  source = "../../modules/static_site"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  project = var.project
  env     = var.env

  route53_zone_id = var.route53_zone_id

  # STOP site hostname (Route53 record inside the module uses this)
  static_fqdn = "stop.anzyworld.com"

  # Certificate domains (CloudFront HTTPS)
  primary_domain    = "stop.anzyworld.com"
  alternate_domains = ["nas.anzyworld.com"]

  tags = local.tags
}

# Route53 GEO routing for nas.anzyworld.com
# US -> Dynamic ALB
resource "aws_route53_record" "nas_us" {
  zone_id = var.route53_zone_id
  name    = "nas.anzyworld.com"
  type    = "A"

  set_identifier = "us-users-dynamic"

  geolocation_routing_policy {
    country = "US"
  }

  alias {
    name                   = module.ecs_dynamic_site.alb_dns_name
    zone_id                = module.ecs_dynamic_site.alb_zone_id
    evaluate_target_health = true
  }
}

# Default (everyone else) -> Static CloudFront STOP page
resource "aws_route53_record" "nas_default" {
  zone_id = var.route53_zone_id
  name    = "nas.anzyworld.com"
  type    = "A"

  set_identifier = "non-us-users-static"

  geolocation_routing_policy {
    country = "*"
  }

  alias {
    name                   = module.static_site.cloudfront_domain_name
    zone_id                = module.static_site.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

module "intranet_app" {
  source = "../../modules/intranet_app"


  project = var.project
  env     = var.env
  tags    = local.tags

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  vpc_cidr           = "10.0.0.0/16"

  route53_zone_id = aws_route53_zone.private_anzyworld.zone_id
  intranet_fqdn   = "intranet.anzyworld.com"

  instance_type = "t3.micro"
  http_port     = 80

  ami_id = "ami-026992d753d5622bc" # <-- the AMI currently used by the EC2

}

resource "aws_route53_zone" "private_anzyworld" {
  name = "anzyworld.com"

  vpc {
    vpc_id = module.network.vpc_id
  }

  comment = "Private hosted zone for intranet/internal names"

  tags = local.tags
}

module "auditing" {
  source = "../../modules/auditing"

  project = var.project
  env     = var.env
  tags    = local.tags

  alerts_topic_arn = module.rds.alerts_topic_arn # or wherever your SNS output is
}

module "grafana" {
  source = "../../modules/grafana"

  project = var.project
  env     = var.env
  tags    = local.tags

  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
}

module "vpc_flow_logs" {
  source  = "../../modules/vpc_flow_logs"
  project = var.project
  env     = var.env
  tags    = local.tags

  vpc_id            = module.network.vpc_id
  retention_in_days = 90
}

module "budget" {
  source  = "../../modules/budget"
  project = var.project
  env     = var.env
  tags    = local.tags

  limit_usd    = 30
  alert_emails = ["anselmebsiy59@gmail.com"]
}

module "security_hub" {
  source  = "../../modules/security_hub"
  project = var.project
  env     = var.env
}

