variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

locals {
  region = 'us-west-2'

  tags = {
    site = "dailywombat"
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.region
}

terraform {
  backend "s3" {
    bucket = "daily-wombat-terraform-state"
    key    = "main"
    region = var.region
  }
}
