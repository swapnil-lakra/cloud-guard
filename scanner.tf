data "archive_file" "scanner_zip" {
  type        = "zip"
  source_file = "lambda/index.py"
  output_path = "lambda_payload.zip"
}

resource "aws_lambda_function" "scanner" {
  function_name    = "${var.project_name}-scanner"
  role             = aws_iam_role.lambda_scanner.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  memory_size      = 128
  filename         = data.archive_file.scanner_zip.output_path
  source_code_hash = data.archive_file.scanner_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.findings.name
      SNS_TOPIC_ARN  = aws_sns_topic.cloudguard_alerts.arn
    }
  }

  depends_on = [aws_iam_role_policy.scanner_permissions, aws_dynamodb_table.findings]
}

resource "aws_cloudwatch_event_rule" "hourly_scan" {
  name                = "${var.project_name}-hourly-scan"
  description         = "Trigger CloudWatch scanner every hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "invoke_scanner" {
  rule      = aws_cloudwatch_event_rule.hourly_scan.name
  target_id = "ScannerLambda"
  arn       = aws_lambda_function.scanner.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scanner.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.hourly_scan.arn
}