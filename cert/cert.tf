variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

locals {
  site_name = "www.dailywombat.com"

  tags = {
    site = "dailywombat"
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = "us-east-1"
}

terraform {
  backend "remote" {
    organization = "dailywombat"

    workspaces {
      prefix = "cert-"
    }
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = local.site_name
  validation_method = "EMAIL"
  # validation_method = "DNS"

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

output "cert_arn" {
  value = aws_acm_certificate.cert.arn
}
