variable "environment" {
  description = "A string of enviromnent variable name"
  type        = string
}

variable "app_prefix" {
  description = "A string identifying the specific application/project"
  type        = string
}

variable "asset_name" {
  description = "Application Asset/Resource root name"
}

variable "description" {
  description = "Asset/Application component description and purpose statement"
  type        = string
}

variable "test_tags" {
  description = "Map of tags required for AWS resources for test compliance purposes"
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

  default = {
    CostCenter             = "500014L3"
    AssetOwner             = "Ankur.Agarwal@test.com"
    CiId                   = "notAssigned"
    AsaqId                 = "ASAQ-2601948"
    AppName                = "NetflexHPN Dashboard"
    Purpose                = "rds secrets"
    Environment            = "dev"
    AssetName              = "test-us-da-hpp-dev"
    DataSubjectArea        = "pharmacy"
    ComplianceDataCategory = "none"
    DataClassification     = "proprietary"
    BackupOwner            = "sriharsha.valeti@test.com"
  }
}


variable "NETFLEX_RDS_MASTER_USR" {}
variable "NETFLEX_RDS_MASTER_PSW" {}

variable "runtime" {
  description = "Runtime of the Lambda Function"
  default     = "python3.7"
}

variable "lambda_role_arn" {
  description = "lambda_role_arn created by RAAS"
  type        = string
}

variable "lambda_filename" {
  description = "Local path to package. Mutually exclusive to S3 vars. To use dummy package, use lambda_function_payload.zip"
}

variable "lambda_code_bucket" {
  description = "Deployment package bucket"
}

variable "lambda_code_key" {
  description = "Key of deployment package in bucket"
}

#variable "pass" {
#  type = string
#}


variable "vpc_tfstate_bucket" {
  description = "A string with the name of the bucket containing VPC tfstate file"
  type        = string
}

variable "vpc_tfstate_key" {
  description = "A string with the name of the key for VPC tfstate file"
  type        = string
}

variable "security_group_id" {
  default = ""
}

variable "log_group_retention_in_days" {
  description = "Log group retention period"
  default     = 30
}

variable "alert_funnel_arn" {
  description = "The SNS Topic to send alerts to the funnel"
  type        = list(string)
}

variable "splunk_destination_arn" {
  description = "ARN destination to push cloud watch logs to splunk."
  default     = "arn:aws:logs:us-east-1:746770431074:destination:CentralizedLogging-v2-Destination"
  #default = "/Enterprise/CentralLoggingDestinationArn"

  # param store version: /Enterprise/CentralLoggingDestinationArn
}

variable "alarm_actions" {
  description = "The SNS Topic to send alerts to the funnel"
  type        = list(string)
  default     = []
}

variable "alert_funnel_app_name" {
  description = "A string for the alert funnel app name needed for funnel to operate"
  type        = string
  default     = "Rx-sco"
}
