resource "aws_route53_record" "site_dns_record" {
  zone_id = data.terraform_remote_state.hostedzone.outputs.site_zone_id

  name = local.domain
  type = "A"

  alias {
    name                   = aws_cloudfront_distribution.site_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.site_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
