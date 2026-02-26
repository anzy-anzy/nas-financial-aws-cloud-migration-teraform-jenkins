output "tgw_id" {
  value = aws_ec2_transit_gateway.this.id
}

output "tgw_arn" {
  value = aws_ec2_transit_gateway.this.arn
}

output "nas_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.nas.id
}

output "ram_share_arn" {
  value = aws_ram_resource_share.tgw.arn
}