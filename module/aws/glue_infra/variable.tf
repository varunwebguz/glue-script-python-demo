variable "test_tags" {
  description = "Map of tags required for AWS resource"
  type = object({
    AsaqId                 = string
    AssetOwner             = string
    CiId                   = string
    CostCenter             = string
    AppName                = string
    Purpose                = string
    AssetName              = string
    CostCenter             = string
    Environment            = string
    DataSubjectArea        = string
    ComplianceDataCategory = string
    DataClassification     = string
    BackupOwner            = string
  })
}

variable "additional_tags" {
  description = "Map of additional tags required for AWS resources for test compliance purposes"
  type = object({
    DataSubjectArea        = string
    ComplianceDataCategory = string
    DataClassification     = string

  })

  default = {
    DataSubjectArea        = "pharmacy"
    ComplianceDataCategory = "none"
    DataClassification     = "proprietary"
  }
}

variable "netflex_glueclaim_config" {
  description = "Variable for netflex connection information"
  type = object({
    secret_name          = string
    region_name          = string
    dbname               = string
    port                 = string
    artifacts_bucket     = string
    artifacts_bucket_key = string
    claim_version          = string
  })
}

variable "port" {
  description = "String representing the deployment environment"
  type        = string
}

variable "environment" {
  description = "String representing the deployment environment"
  type        = string
}

variable "glue_netflex_claim_deploy_job" {
  description = "Unique name to identify your glue job."
  type        = string
}

variable "description" {
  type    = string
  default = "Job to create table  for netflex application"
}

# GLUE ON DEMAND TRIGGERS #
variable "glue_netflex_claim_deploy_trigger" {
  description = "Unique name to identify your glue job trigger."
  type        = string
}

variable "glue_role_arn" {
  description = "glue_role_arn created by RAAS for netflex application"
  type        = string
}

variable "aws_glue_connection" {
  description = "List of Jobs"
  type        = list(any)
}

variable "availability_zone_1" {
  type    = string
  default = "us-east-1a"
}


# Glue variables
variable "glue_version" {
  type    = string
  default = "1.0"
}

variable "glue_role_name" {
  type    = string
  default = "NETFLEXETLGLUE"
}


variable "glue_max_capacity" {
  type    = string
  default = "1"
}

variable "glue_max_concurrent_runs" {
  type    = string
  default = "1"
}

variable "glue_job_timeout" {
  type    = string
  default = "300"
}

variable "glue_max_retries" {
  type    = string
  default = "0"
}

variable "glue_python_version" {
  default = 3
}

variable "db_iam_roles" {
  type = list(string)
}

# S3 variables

#variable "s3_data_bucket" {
#  type = string
#}

variable "vpc_tfstate_bucket" {
  description = "A string with the name of the bucket containing VPC tfstate file"
  type        = string
}

variable "vpc_tfstate_key" {
  description = "A string with the name of the bucket containing VPC tfstate file"
  type        = string
}


variable "artifacts_bucket" {
  description = "A string with the name of the bucket containing scripts and other file"
  type        = string
}


#variable "glue_job_name" {
#  description = "Unique name to identify your glue ingestion job."
#  type        = string
#}


variable "glue_default_arguments" {
  type = map(string)
  default = {
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-metrics"                   = "true"
    "--job-language"                     = "Python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
  }
}

variable "security_group_id" {
  type    = string
  default = ""
}



############################### alerts and logging ########################

variable "alarm_sns_topic_arns" {
  description = "SNS Topics to send events to (defaults to non-prod -- dev/test)"
  default     = ["arn:aws:sns:us-east-1:929468956630:cloudwatch-alarm-funnel"]
}

variable "log_group_retention_in_days" {
  description = "Log group retention period"
  default     = 30
}

variable "splunk_destination_arn" {
  description = "ARN destination to push cloud watch logs to splunk."
  default     = "arn:aws:logs:us-east-1:746770431074:destination:CentralizedLogging-v2-Destination"
  # param store version: /Enterprise/CentralLoggingDestinationArn
}

variable "alert_funnel_arn" {
  description = "The SNS Topic to send alerts to the funnel"
  type        = list(string)
}

variable "app_prefix" {
  description = "A string for the alert funnel app name needed for funnel to operate"
  type        = string
  default     = "netflex"
}