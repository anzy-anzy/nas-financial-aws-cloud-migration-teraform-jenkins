output "intranet_instance_id" {
  value = aws_instance.intranet.id
}

output "intranet_private_ip" {
  value = aws_instance.intranet.private_ip
}

output "intranet_url" {
  value = "http://${var.intranet_fqdn}"
}
