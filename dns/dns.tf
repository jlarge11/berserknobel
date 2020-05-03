variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

locals {
  site_name = "dailywombat"
  domain = "${local.site_name}.com"

  tags = {
    site = local.site_name
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = "us-west-1"
}

terraform {
  backend "remote" {
    organization = "dailywombat"

    workspaces {
      prefix = "dns-"
    }
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
