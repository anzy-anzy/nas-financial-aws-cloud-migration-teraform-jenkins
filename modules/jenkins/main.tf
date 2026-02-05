resource "aws_security_group" "jenkins" {
  name        = "${var.project}-${var.env}-jenkins-sg"
  description = "Jenkins SG (private access via SSM port-forward)"
  vpc_id      = var.vpc_id

  # NO INGRESS (no 22, no 8080) -> private only

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-${var.env}-jenkins-sg" })
}

data "aws_iam_policy_document" "ssm_assume" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "jenkins_ssm" {
  name               = "${var.project}-${var.env}-jenkins-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.jenkins_ssm.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project}-${var.env}-jenkins-profile"
  role = aws_iam_role.jenkins_ssm.name
}

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  jenkins_user_data = <<-EOF
    #!/bin/bash
    set -e

    yum update -y
    yum install -y java-17-amazon-corretto git

    # Jenkins repo
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

    yum install -y jenkins

    systemctl enable jenkins
    systemctl start jenkins

    # Allow Jenkins to bind on 8080 (default)
    # Access is via SSM port forwarding (localhost:8080)
  EOF
}

resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.al2.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name
  associate_public_ip_address = false
  user_data                   = local.jenkins_user_data

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-jenkins"
  })
}
