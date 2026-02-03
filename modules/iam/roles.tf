locals {
  name_prefix = "${var.project}-${var.env}"
}

# -------------------------
# CloudSpace Engineers Role
# Admin access but NO billing
# -------------------------
resource "aws_iam_role" "cloudspace_engineers" {
  name               = "${local.name_prefix}-CloudSpaceEngineersRole"
  assume_role_policy = data.aws_iam_policy_document.assume_nas_roles.json
  tags = {
    Project     = var.project
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "cloudspace_admin" {
  role       = aws_iam_role.cloudspace_engineers.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "cloudspace_deny_billing_attach" {
  role       = aws_iam_role.cloudspace_engineers.name
  policy_arn = aws_iam_policy.deny_billing.arn
}

# -------------------------
# NAS Security Team Role
# Full admin INCLUDING billing
# -------------------------
resource "aws_iam_role" "nas_security_team" {
  name               = "${local.name_prefix}-NASSecurityTeamRole"
  assume_role_policy = data.aws_iam_policy_document.assume_nas_roles.json
  tags = {
    Project     = var.project
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "security_admin" {
  role       = aws_iam_role.nas_security_team.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# -------------------------
# NAS Operations Team Role
# Admin but ONLY in us-east-1
# -------------------------
resource "aws_iam_role" "nas_operations_team" {
  name               = "${local.name_prefix}-NASOperationsTeamRole"
  assume_role_policy = data.aws_iam_policy_document.assume_nas_roles.json
  tags = {
    Project     = var.project
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "ops_admin" {
  role       = aws_iam_role.nas_operations_team.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "ops_deny_other_regions_attach" {
  role       = aws_iam_role.nas_operations_team.name
  policy_arn = aws_iam_policy.deny_non_useast1.arn
}

# -------------------------
# N2G Auditing Role (in NAS account)
# Cross-account assume role from N2G account
# -------------------------
resource "aws_iam_role" "n2g_auditing" {
  name               = "${local.name_prefix}-N2GAuditingRole"
  assume_role_policy = data.aws_iam_policy_document.assume_n2g_role.json
  tags = {
    Project     = var.project
    Environment = var.env
  }
}

# Minimal permissions for now (we will expand later once intranet/RDS exist)
resource "aws_iam_role_policy_attachment" "n2g_minimal_readonly_attach" {
  role       = aws_iam_role.n2g_auditing.name
  policy_arn = aws_iam_policy.n2g_minimal_readonly.arn
}
