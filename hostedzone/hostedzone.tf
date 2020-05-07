resource "aws_route53_zone" "site_zone" {
  name = local.domain
  tags = local.tags
}

output "site_zone_id" {
  value = aws_route53_zone.site_zone.id
}
