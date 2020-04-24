variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

locals {
  s3_bucket = "daily-wombat-terraform-state"
  state_lock_table = "tf_state_lock"
  admin_user_arn = "arn:aws:iam::848364476882:user/jlarge"
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = "us-west-2"
}

data "template_file" "remotestate_bucket_full_access" {
  template = "${file("${path.module}/templates/bucket_full_access.tpl")}"

  vars = {
    user_arn = local.admin_user_arn
    s3_bucket = local.s3_bucket
  }
}

resource "aws_s3_bucket" "daily-wombat-terraform-state" {
  bucket = "daily-wombat-terraform-state"
  acl    = "private"
  policy = data.template_file.remotestate_bucket_full_access.rendered

  versioning {
    enabled = true
  }

  tags = {
    site = "dailywombat"
  }
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = local.state_lock_table
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

data "template_file" "state_lock_table_access" {
  template = "${file("${path.module}/templates/state_lock_table_access.tpl")}"

  vars = {
    state_lock_table = local.state_lock_table
  }
}

resource "aws_iam_user_policy" "tf_state_lock_table_access" {
  name = "tf_state_lock_table_access"
  user = "jlarge"

  policy = data.template_file.state_lock_table_access.rendered
}
