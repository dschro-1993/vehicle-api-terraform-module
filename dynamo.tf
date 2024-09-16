# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table

resource "aws_dynamodb_table" "dynamodb_table" {
  # {...}

  name         = "${var.app_name}-${var.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key_name

  # deletion_protection_enabled = var.deletion_protection_enabled

  # ttl {
  #   attribute_name = var.dynamo_ttl_attribute_name
  #   enabled        = var.dynamo_ttl_enabled
  # }

  # point_in_time_recovery {
  #   enabled = var.dynamo_point_in_time_recovery_enabled
  # }

  attribute {
    name = var.hash_key_name
    type = var.hash_key_type
  }

  # dynamic global_secondary_index {}

  # dynamic attribute {}

  # {...}
}
