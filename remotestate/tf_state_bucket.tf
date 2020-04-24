locals {
  state_bucket = "daily-wombat-terraform-state"
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

data "template_file" "tf_state_bucket_access" {
  template = "${file("${path.module}/templates/tf_state_bucket_access.tpl")}"

  vars = {
    user_arn = "arn:aws:iam::848364476882:user/jlarge"
    state_bucket = local.state_bucket
  }
}
