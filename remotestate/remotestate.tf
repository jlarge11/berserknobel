variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

locals {
  site = "dailywombat"
  state_bucket = "daily-wombat-terraform-state"
  state_lock_table = "tf_state_lock"
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = "us-west-2"
}

data "template_file" "tf_state_bucket_access" {
  template = "${file("${path.module}/templates/tf_state_bucket_access.tpl")}"

  vars = {
    user_arn = "arn:aws:iam::848364476882:user/jlarge"
    state_bucket = local.state_bucket
  }
}

resource "aws_s3_bucket" "daily_wombat_terraform_state" {
  bucket = local.state_bucket
  acl    = "private"
  policy = data.template_file.tf_state_bucket_access.rendered

  versioning {
    enabled = true
  }

  tags = {
    site = local.site
  }
}

resource "aws_dynamodb_table" "tf_state_lock" {
  name           = local.state_lock_table
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    site = local.site
  }
}

data "template_file" "tf_state_lock_table_access" {
  template = "${file("${path.module}/templates/tf_state_lock_table_access.tpl")}"

  vars = {
    state_lock_table = local.state_lock_table
  }
}

resource "aws_iam_user_policy" "tf_state_lock_table_access" {
  name = "tf_state_lock_table_access"
  user = "jlarge"

  policy = data.template_file.tf_state_lock_table_access.rendered
}
