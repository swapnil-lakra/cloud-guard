resource "aws_dynamodb_table" "findings" {
  name           = "cloudguard-findings"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "account_id"
  range_key      = "finding_id"

  attribute {
    name = "account_id"
    type = "S"
  }

  attribute {
    name = "finding_id"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-findings"
  }
}