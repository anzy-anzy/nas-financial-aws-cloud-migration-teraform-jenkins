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
    sid     = "DenyOutsideUsEast1"
    effect  = "Deny"
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
# N2G Well-Architected Tool Only (Project requirement)
# N2G gets full access to Well-Architected Tool and NOTHING else.
# -------------------------
resource "aws_iam_policy" "n2g_minimal_readonly" {
  name        = "${var.project}-${var.env}-N2GWellArchitectedOnly"
  description = "N2G has full access to AWS Well-Architected Tool and nothing else."
  policy      = data.aws_iam_policy_document.n2g_minimal_readonly.json
}

data "aws_iam_policy_document" "n2g_minimal_readonly" {
  statement {
    sid     = "AllowFullWellArchitectedAccess"
    effect  = "Allow"
    actions = [
      "wellarchitected:*"
    ]
    resources = ["*"]
  }
}