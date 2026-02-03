output "cloudspace_engineers_role_arn" {
  value = aws_iam_role.cloudspace_engineers.arn
}

output "nas_security_team_role_arn" {
  value = aws_iam_role.nas_security_team.arn
}

output "nas_operations_team_role_arn" {
  value = aws_iam_role.nas_operations_team.arn
}

output "n2g_auditing_role_arn" {
  value = aws_iam_role.n2g_auditing.arn
}
