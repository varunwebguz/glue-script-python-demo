terraform {
  backend "s3" {}
}

##
resource "aws_cloudwatch_log_group" "netflex_log_group" {
  name              = "/aws-glue/jobs/${var.glue_netflex_claim_deploy_job}"
  retention_in_days = 14

}

resource "aws_glue_job" "netflex_claim_deploy" {
  name         = var.glue_netflex_claim_deploy_job
  description  = var.description
  role_arn     = var.glue_role_arn
  max_capacity = var.glue_max_capacity
  glue_version = var.glue_version
  timeout      = var.glue_job_timeout
  max_retries  = var.glue_max_retries
  connections  = var.aws_glue_connection

  command {
    script_location = "s3://${var.netflex_glueclaim_config.artifacts_bucket}/${var.netflex_glueclaim_config.artifacts_bucket_key}/python/claim_deploy.py"
    python_version  = var.glue_python_version
    name            = "pythonshell"
  }

  execution_property {
    max_concurrent_runs = var.glue_max_concurrent_runs
  }

  default_arguments = merge(var.glue_default_arguments, tomap(
    {
      "--job-bookmark-option"              = "job-bookmark-enable"
      "--enable-metrics"                   = ""
      "--job-language"                     = "Python"
      "--enable-continuous-cloudwatch-log" = "true"
      "--enable-continuous-log-filter"     = "true"
      "--scriptLocation"                   = "s3://${var.netflex_glueclaim_config.artifacts_bucket}/${var.netflex_glueclaim_config.artifacts_bucket_key}/python/claim_deploy.py"
      "--continuous-log-logGroup"          = "/aws-glue/jobs/${var.glue_netflex_claim_deploy_job}"
      "--extra-py-files"                   = "s3://${var.netflex_glueclaim_config.artifacts_bucket}/${var.netflex_glueclaim_config.artifacts_bucket_key}/lib/psycopg2-2.7.7-cp36-cp36m-manylinux1_x86_64.whl"
      "--artifacts_bucket"                 = var.artifacts_bucket
		  "--s3_bucket_360"                    = var.config_360.s3_bucket_360
		  "--db_host_360"                      = var.config_360.db_host_360
		  "--db_name_360"                      = var.config_360.db_name_360
		  "--db_port_360"                      = var.config_360.db_port_360
		  "--cluster_id_360"                   = var.config_360.cluster_id_360
		  "--db_user_360"                      = var.config_360.db_user_360
	    "--assumed_rolearn_360"              = var.config_360.assumed_rolearn_360
		  "--database"                         = var.config_360.database
		  "--redshift_cluster_name"            = var.config_360.redshift_cluster_name
		  "--continuous-log-logGroup"          = "/aws-glue/jobs/${var.glue_netflex_claim_deploy_job}"
      "--rds_secret_name"                  = var.netflex_glueclaim_config.secret_name
      "--rds_region_name"                  = var.netflex_glueclaim_config.region_name
      "--rds_dbname"                       = var.netflex_glueclaim_config.dbname
      "--rds_host"                         = data.aws_rds_cluster.rxcdc_aurora_cluster.endpoint
      "--rds_port"                         = var.netflex_glueclaim_config.port
      "--rds_artifacts_bucket"             = var.netflex_glueclaim_config.artifacts_bucket
      "--rds_artifacts_bucket_key"         = var.netflex_glueclaim_config.artifacts_bucket_key
    }
  ))
  tags = merge(var.test_tags, map("Name", var.glue_netflex_claim_deploy_job), map("resourceName", var.glue_netflex_claim_deploy_job))
}
