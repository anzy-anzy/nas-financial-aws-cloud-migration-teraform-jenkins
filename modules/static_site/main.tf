data "aws_region" "current" {}

# S3 bucket for static "blocked" page
resource "aws_s3_bucket" "this" {
  bucket = "${var.project}-${var.env}-static-stop"

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-static-stop"
  })
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Upload the static denial page
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.this.id
  key          = "index.html"
  content_type = "text/html"

  content = <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Access Restricted</title>
  </head>
  <body style="font-family: Arial; margin: 40px;">
    <h1>Access Restricted</h1>
    <p>Sorry, you are not in a country authorized to access this web page.</p>
  </body>
</html>
EOF

  etag = md5(<<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Access Restricted</title>
  </head>
  <body style="font-family: Arial; margin: 40px;">
    <h1>Access Restricted</h1>
    <p>Sorry, you are not in a country authorized to access this web page.</p>
  </body>
</html>
EOF
  )
}

# CloudFront OAC (recommended)
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project}-${var.env}-oac"
  description                       = "OAC for static stop site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ACM certificate (CloudFront requires us-east-1)
resource "aws_acm_certificate" "static" {
  provider                  = aws.us_east_1
  domain_name               = var.primary_domain
  subject_alternative_names = var.alternate_domains
  validation_method         = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-acm-${var.primary_domain}"
  })
}

resource "aws_route53_record" "static_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.static.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "static" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.static.arn
  validation_record_fqdns = [for r in aws_route53_record.static_cert_validation : r.fqdn]
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "this" {
  depends_on = [aws_acm_certificate_validation.static]

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "NAS static stop site"
  default_root_object = "index.html"

  # ✅ ONLY ONCE
  aliases = concat([var.primary_domain], var.alternate_domains)

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id                = "s3-static-stop"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-static-stop"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.static.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-cf-static-stop"
  })
}

# Allow CloudFront (OAC) to read from S3 bucket
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

# Route53 record for PRIMARY stop domain -> CloudFront
resource "aws_route53_record" "static_alias" {
  zone_id = var.route53_zone_id
  name    = var.primary_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
