locals {
  state_lock_table = "tf_state_lock"
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

  tags = local.tags
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
