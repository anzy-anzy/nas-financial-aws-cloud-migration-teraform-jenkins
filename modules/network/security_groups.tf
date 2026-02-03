# Public ALB SG (dynamic site)
resource "aws_security_group" "alb_public" {
  name        = "${var.project}-${var.env}-sg-alb-public"
  description = "Public ALB SG: allow HTTPS from internet"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Optional: allow HTTP -> redirect to HTTPS (only if you configure listener redirect)
  ingress {
    description = "HTTP from internet (optional redirect)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-sg-alb-public"
  })
}

# App SG for ECS tasks (dynamic site)
resource "aws_security_group" "app_dynamic" {
  name        = "${var.project}-${var.env}-sg-app-dynamic"
  description = "Dynamic app SG: allow traffic from public ALB only"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "App traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_public.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-sg-app-dynamic"
  })
}

# DB SG (RDS) - allow only from app SG
resource "aws_security_group" "db" {
  name        = "${var.project}-${var.env}-sg-db"
  description = "DB SG: allow MySQL from dynamic app SG only"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "MySQL from app"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_dynamic.id]
  }

  egress {
    description = "All outbound (RDS managed)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-sg-db"
  })
}

# Internal ALB SG (for intranet - HTTP internal only)
resource "aws_security_group" "alb_internal" {
  name        = "${var.project}-${var.env}-sg-alb-internal"
  description = "Internal ALB SG: allow HTTP from inside VPC"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from VPC CIDR"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-sg-alb-internal"
  })
}
