
resource "aws_cloudwatch_log_group" "rotation_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.rotation_lambda.function_name}"
  tags              = merge(var.test_tags)
  retention_in_days = var.log_group_retention_in_days
}


//--- Centralized Logging Splunk Subscription for Lambda Log Group
resource "aws_cloudwatch_log_subscription_filter" "splunk_subscription" {
  count           = var.splunk_destination_arn == null ? 0 : 1
  name            = "${aws_lambda_function.rotation_lambda.function_name}_splunk_subscription"
  log_group_name  = aws_cloudwatch_log_group.rotation_lambda.name
  filter_pattern  = ""
  destination_arn = var.splunk_destination_arn
  depends_on      = [aws_cloudwatch_log_group.rotation_lambda]
  distribution    = "ByLogStream"
}

resource "aws_cloudwatch_metric_alarm" "rotation_lambda_alarm" {
  alarm_name          = "${aws_lambda_function.rotation_lambda.function_name}-error-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = "120"
  threshold           = "0"
  treat_missing_data  = "notBreaching"
  alarm_description   = "${var.environment}|CRITICAL|${var.alert_funnel_app_name}|Errors > 0"
  alarm_actions       = var.alert_funnel_arn

  dimensions = {
    FunctionName = aws_lambda_function.rotation_lambda.function_name
  }

  tags = merge(
    var.test_tags,
    {
      "Name" = "AWS_Alarm"
    }
  )
}