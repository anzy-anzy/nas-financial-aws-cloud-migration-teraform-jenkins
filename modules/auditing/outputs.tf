output "cloudtrail_bucket_name" {
  value = aws_s3_bucket.cloudtrail.bucket
}

output "cloudtrail_name" {
  value = aws_cloudtrail.this.name
}
