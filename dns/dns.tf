resource "null_resource" "warning" {
  provisioner "local-exec" {
    command = "echo 'Did you remember to use the tfapply script?  Running terraform apply by itself will put the name servers on the newly created hosted zone out of sync with the ones that are in the domain registration.'"
  }
}

resource "aws_route53_zone" "site_zone" {
  name = local.domain
  tags = local.tags
}

resource "aws_route53_record" "site_dns_record" {
  zone_id = aws_route53_zone.site_zone.zone_id

  name = local.domain
  type = "A"

  alias {
    name                   = data.terraform_remote_state.site.outputs.site_distribution_domain_name
    zone_id                = data.terraform_remote_state.site.outputs.site_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}
