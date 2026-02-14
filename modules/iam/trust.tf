# If trusted_nas_principals is empty, default to NAS account root.
locals {
  effective_nas_principals = length(var.trusted_nas_principals) > 0 ? var.trusted_nas_principals : [
    "arn:aws:iam::${var.nas_account_id}:root"
  ]
}

data "aws_iam_policy_document" "assume_nas_roles" {
  statement {
    sid     = "AllowAssumeFromNASPrincipals"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = local.effective_nas_principals
    }
  }
}

data "aws_iam_policy_document" "assume_n2g_role" {
  statement {
    sid     = "AllowAssumeFromN2GUser"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.n2g_account_id}:user/N2G-AUDITING"]
    }

    dynamic "condition" {
      for_each = var.n2g_external_id != "" ? [1] : []
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [var.n2g_external_id]
      }
    }
  }
}

