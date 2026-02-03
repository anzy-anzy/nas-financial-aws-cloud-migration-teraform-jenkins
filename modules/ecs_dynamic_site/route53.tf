# app.anzyworld.com -> ALB
resource "aws_route53_record" "dynamic_alias" {
  zone_id = var.route53_zone_id
  name    = var.dynamic_fqdn
  type    = "A"

  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}
