variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "environment" {}

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

data "terraform_remote_state" "site" {
  backend = "remote"

  config = {
    organization = local.site_name

    workspaces = {
      name = "site-${var.environment}"
    }
  }
}
