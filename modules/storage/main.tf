resource "aws_kms_key" "pii_key" {
  description             = "KMS key for NAS PII S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "pii_key_alias" {
  name          = "alias/${var.kms_alias_name}"
  target_key_id = aws_kms_key.pii_key.key_id
}

resource "aws_s3_bucket" "pii_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.pii_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.pii_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.pii_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.pii_key.arn
    }
  }
}

# Lifecycle: frequently accessed 30 days, then archive; keep records 5 years
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.pii_bucket.id

  rule {
    id     = "hot-30days-archive-5years"
    status = "Enabled"
    filter {}

    transition {
      days          = var.archive_after_days
      storage_class = var.archive_storage_class
    }

    expiration {
      days = var.expire_after_days
    }
  }
}

data "aws_iam_policy_document" "deny_unencrypted_put" {
  statement {
    sid     = "DenyUnEncryptedObjectUploads"
    effect  = "Deny"
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.pii_bucket.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.pii_bucket.id
  policy = data.aws_iam_policy_document.deny_unencrypted_put.json
}