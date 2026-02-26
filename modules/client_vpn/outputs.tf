output "vpn_endpoint_id" {
  value = aws_ec2_client_vpn_endpoint.this.id
}

output "vpn_sg_id" {
  value = aws_security_group.vpn.id
}
