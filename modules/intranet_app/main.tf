data "aws_region" "current" {}

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# --- Security Group: allow HTTP only from inside VPC (or corp CIDR if provided) ---
locals {
  allowed_http_cidrs = var.corp_cidr != "" ? [var.corp_cidr] : [var.vpc_cidr]
}

resource "aws_security_group" "intranet" {
  name        = "${var.project}-${var.env}-sg-intranet"
  description = "Intranet EC2 SG (private only)"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from allowed internal CIDRs"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = local.allowed_http_cidrs
  }

  # no SSH rule at all

  egress {
    description = "Outbound to internet via NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-${var.env}-sg-intranet" })
}

# --- IAM Role + Instance Profile for SSM ---
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_role" {
  name               = "${var.project}-${var.env}-intranet-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.project}-${var.env}-intranet-ec2-profile"
  role = aws_iam_role.ssm_role.name
}

# --- EC2 in PRIVATE subnet, no public IP ---
resource "aws_instance" "intranet" {
  ami                    = data.aws_ami.al2.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.intranet.id]
  iam_instance_profile   = aws_iam_instance_profile.this.name

  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              set -eux
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              echo "<h1>Intranet OK - ${var.project}-${var.env}</h1><p>Private EC2 via SSM</p>" > /var/www/html/index.html
              systemctl start httpd
              EOF

  tags = merge(var.tags, { Name = "${var.project}-${var.env}-intranet-ec2" })
}

# --- Private Route53 record pointing to the private IP ---
resource "aws_route53_record" "intranet" {
  zone_id = var.route53_zone_id
  name    = var.intranet_fqdn
  type    = "A"
  ttl     = 60
  records = [aws_instance.intranet.private_ip]
}
