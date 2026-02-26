
resource "aws_security_group" "vpn" {
  name        = "${var.project}-${var.env}-sg-vpn"
  description = "Security group for Client VPN"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow VPN client network"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.client_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-sg-vpn"
  })
}


resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "${var.project}-${var.env}-client-vpn"
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block
  split_tunnel           = true
  vpc_id                 = var.vpc_id

  dns_servers        = ["10.0.0.2"]
  security_group_ids = [aws_security_group.vpn.id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_root_certificate_arn
  }

  connection_log_options {
    enabled = false
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-client-vpn"
  })
}

resource "aws_ec2_client_vpn_network_association" "assoc" {
  count                  = length(var.private_subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = var.private_subnet_ids[count.index]
}


resource "aws_ec2_client_vpn_authorization_rule" "vpc_access" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
}
