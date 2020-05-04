output "site_distribution_domain_name" {
  value = aws_cloudfront_distribution.site_distribution.domain_name
}

output "site_distribution_hosted_zone_id" {
  value = aws_cloudfront_distribution.site_distribution.hosted_zone_id
}
