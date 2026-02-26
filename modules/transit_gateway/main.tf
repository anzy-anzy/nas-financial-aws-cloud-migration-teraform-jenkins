resource "aws_ec2_transit_gateway" "this" {
  description = "${var.project}-${var.env} TGW"

  dns_support                    = "enable"
  vpn_ecmp_support               = "enable"
  auto_accept_shared_attachments = "disable"

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-tgw"
  })
}

# Attach NAS VPC to TGW (use private subnets)
resource "aws_ec2_transit_gateway_vpc_attachment" "nas" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = var.nas_vpc_id
  subnet_ids         = var.nas_private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-tgw-nas-attach"
  })
}

# Route NAS private RT to N2G CIDR via TGW
resource "aws_route" "nas_to_n2g" {
  route_table_id         = var.nas_private_route_table_id
  destination_cidr_block = var.n2g_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.this.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.nas]
}

# Share TGW to N2G via RAM
resource "aws_ram_resource_share" "tgw" {
  name                      = "${var.project}-${var.env}-tgw-share"
  allow_external_principals = true

  tags = var.tags
}

resource "aws_ram_principal_association" "n2g" {
  principal          = var.n2g_account_id
  resource_share_arn = aws_ram_resource_share.tgw.arn
}

resource "aws_ram_resource_association" "tgw" {
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}