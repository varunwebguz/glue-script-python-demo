##----glue_netflex_claim_deploy_trigger----##
resource "aws_glue_trigger" "netflex_claim_deploy_trigger" {
  name = var.glue_netflex_claim_deploy_trigger
  type = "ON_DEMAND"

  actions {
    job_name = aws_glue_job.netflex_claim_deploy.name
  }
}

