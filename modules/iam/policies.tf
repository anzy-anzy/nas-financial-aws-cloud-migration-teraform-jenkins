# -------------------------
# Deny Billing (for CloudSpace Engineers)
# -------------------------
resource "aws_iam_policy" "deny_billing" {
  name        = "${var.project}-${var.env}-DenyBilling"
  description = "Explicitly deny billing/account portal access."
  policy      = data.aws_iam_policy_document.deny_billing.json
}

data "aws_iam_policy_document" "deny_billing" {
  statement {
    sid    = "DenyBilling"
    effect = "Deny"
    actions = [
      "aws-portal:*",
      "billing:*",
      "cur:*",
      "ce:*",
      "account:*",
      "payments:*",
      "purchase-orders:*",
      "invoicing:*",
      "tax:*"
    ]
    resources = ["*"]
  }
}

# -------------------------
# Deny Non-us-east-1 (for NAS Operations Team)
# -------------------------
resource "aws_iam_policy" "deny_non_useast1" {
  name        = "${var.project}-${var.env}-DenyNonUsEast1"
  description = "Explicitly deny actions outside us-east-1."
  policy      = data.aws_iam_policy_document.deny_non_useast1.json
}

data "aws_iam_policy_document" "deny_non_useast1" {
  statement {
    sid    = "DenyOutsideUsEast1"
    effect = "Deny"
    actions = ["*"]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1"]
    }
  }
}

# -------------------------
# N2G minimal readonly (temporary)
# We will tighten/expand later once intranet + DB are deployed.
# -------------------------
resource "aws_iam_policy" "n2g_minimal_readonly" {
  name        = "${var.project}-${var.env}-N2GMinimalReadOnly"
  description = "Minimal read permissions for N2G in NAS account (temporary baseline)."
  policy      = data.aws_iam_policy_document.n2g_minimal_readonly.json
}

data "aws_iam_policy_document" "n2g_minimal_readonly" {
  statement {
    sid    = "AllowDescribeForAudit"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:Describe*",
      "ecs:Describe*",
      "ecs:List*",
      "rds:Describe*",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "logs:Describe*",
      "logs:Get*",
      "logs:FilterLogEvents",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults"
    ]
    resources = ["*"]
  }
}
