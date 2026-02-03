# IAM role for AWS Backup service
data "aws_iam_policy_document" "backup_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup" {
  name               = "${var.project}-${var.env}-aws-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume.json

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-aws-backup-role"
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore_policy" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Backup vault in PRIMARY region (us-east-1)
resource "aws_backup_vault" "primary" {
  name = "${var.project}-${var.env}-backup-vault-primary"

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-backup-vault-primary"
  })
}

# Backup vault in DR region (us-west-2)
resource "aws_backup_vault" "dr" {
  provider = aws.dr
  name     = "${var.project}-${var.env}-backup-vault-dr"

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-backup-vault-dr"
  })
}

# Backup plan with cross-region copy
resource "aws_backup_plan" "this" {
  name = "${var.project}-${var.env}-backup-plan"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.primary.name
    schedule          = "cron(0 2 * * ? *)" # daily at 02:00 UTC

    lifecycle {
      delete_after = 35
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.dr.arn

      lifecycle {
        delete_after = 365 * 5
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-backup-plan"
  })
}

# Select the RDS instance as a protected resource
resource "aws_backup_selection" "rds" {
  name         = "${var.project}-${var.env}-backup-selection-rds"
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.this.id

  resources = [aws_db_instance.this.arn]
}
