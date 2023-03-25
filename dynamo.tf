resource "aws_dynamodb_table" "dynamodb_table" {
  hash_key     = var.hash_key_name
  billing_mode = "PAY_PER_REQUEST"
  name         = "${var.app_name}-${var.env}"
  # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery.html
  point_in_time_recovery {
    enabled = var.pitr_enabled
  }
  attribute {
    name = var.hash_key_name
    type = var.hash_key_type
  }
  # tags = {}
}
