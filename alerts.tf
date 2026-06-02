resource "aws_sns_topic" "cloudguard_alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cloudguard_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}