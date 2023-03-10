output "lambda_arn" {
  value = aws_iam_role.lambda_datadog_metric_to_slack.arn
}
