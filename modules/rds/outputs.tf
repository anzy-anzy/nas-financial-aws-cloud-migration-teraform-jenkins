output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "db_instance_arn" {
  value = aws_db_instance.this.arn
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}

output "alerts_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
