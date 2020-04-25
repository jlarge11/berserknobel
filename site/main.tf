variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

locals {
  main_ui_bucket = "daily-wombat-terraform-state"

  tags = {
    site = "dailywombat"
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "daily-wombat-terraform-state"
    key    = "main"
    region = "us-west-2"
  }
}

resource "aws_dynamodb_table" "funtimes" {
  name           = "funtimes"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = local.tags
}
