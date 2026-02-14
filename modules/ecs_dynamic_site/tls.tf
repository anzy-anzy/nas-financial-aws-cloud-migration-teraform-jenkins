resource "aws_acm_certificate" "dynamic" {
  domain_name               = var.dynamic_fqdn
  validation_method         = "DNS"

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-acm-${var.dynamic_fqdn}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS validation records in Route 53
resource "aws_route53_record" "dynamic_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.dynamic.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "dynamic" {
  certificate_arn         = aws_acm_certificate.dynamic.arn
  validation_record_fqdns = [for r in aws_route53_record.dynamic_cert_validation : r.fqdn]
}
