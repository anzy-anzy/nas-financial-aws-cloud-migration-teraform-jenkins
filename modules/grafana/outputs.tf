output "workspace_id" {
  value = aws_grafana_workspace.this.id
}

output "workspace_endpoint" {
  value = aws_grafana_workspace.this.endpoint
}
