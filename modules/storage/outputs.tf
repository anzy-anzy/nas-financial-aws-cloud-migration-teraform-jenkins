output "bucket_name" {
  value = aws_s3_bucket.pii_bucket.bucket
}

output "kms_key_arn" {
  value = aws_kms_key.pii_key.arn
}