
//--- Centralized Logging Splunk Subscription for Glue Log Group
//#
resource "aws_cloudwatch_log_subscription_filter" "splunk_subscription_netflex_claim" {
  count           = var.splunk_destination_arn == null ? 0 : 1
  name            = "netflex_glue_claim_splunk_subscription"
  log_group_name  = "/aws-glue/jobs/${var.glue_netflex_claim_deploy_job}"
  filter_pattern  = ""
  destination_arn = var.splunk_destination_arn
  depends_on      = [aws_cloudwatch_log_group.netflex_log_group]
  #distribution = "ByLogStream" (default)
}
