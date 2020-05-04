resource "aws_acm_certificate" "cert" {
  domain_name       = local.domain
  validation_method = "EMAIL"
  # validation_method = "DNS"

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}
