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
    AsaqId                 = "Asaq-XXXXXX"
    AppName                = "networkFlexApplication"
    Purpose                = "describe-function-of-resource" /* describe the function of the resource you are creating */
    Environment            = "dev"
    AssetName              = "test-us-da-hpp-dev"
    DataSubjectArea        = "pharmacy"
    ComplianceDataCategory = "none"
    DataClassification     = "proprietary"
    BackupOwner            = "sriharsha.valeti@test.com"
  }
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

variable "environment" {
  description = "String representing the deployment environment"
  type        = string
}

variable "rds_instance_class" {
  description = "The class of EC2 instance to provision"
  type        = string
  default     = "db.r5.large"
}

variable "rds_instance_count" {
  description = "Number of EC2 instances to provision"
  type        = number
  default     = 2
}

variable "rds_engine" {
  description = "The type of db engine to use [aurora, aurora-mysql, aurora-postgresql]"
  type        = string
  default     = "aurora-postgresql"
}

variable "rds_engine_mode" {
  description = "The db engine mode to use [provisioned, serverless]"
  type        = string
  default     = "provisioned"
}

variable "apply_immediately" {
  description = "Boolean value specifying whether changes should be applied immediately to cluster and instances"
  type        = bool
  default     = true
}

variable "port" {
  description = "The port where RDS services listen"
  type        = string
  default     = 5432
}

variable "database_name" {
  description = "The name of the default database to create"
  type        = string
}

variable "rds_engine_version" {
  description = "The version of the particular engine"
  type        = string
  default     = "11.6"
}


variable "db_iam_roles" {
  type = list(string)
}

variable "aurora_instance_count" {
  description = "The number of db instances to create in cluster"
  type        = number
  default     = 2
}

variable "app_prefix" {
  description = "A string identifying the specific application/project"
  type        = string
}

# Cloudwatch vars
variable "cw_namespace" {
  description = "A string of the name of the rds cloudwatch namespace"
  type        = string
  default     = "AWS/RDS"
}

variable "cw_cpu_unit" {
  description = "A string of the the type of rds cloudwatch cpu unit"
  type        = string
  default     = "Percent"
}

variable "cw_statistic" {
  description = "A string of the type of rds cloudwatch statistic method"
  type        = string
  default     = "Average"
}

variable "cw_period" {
  description = "A string of the number of rds cloudwatch period"
  type        = string
  default     = "300"
}

variable "cw_cpu_threshold" {
  description = "A string of the number of the database cloudwatch cpu threshold"
  type        = string
  default     = "75"
}

variable "cw_eval_periods" {
  description = "A string of the number of cloudwatch evaluation periods"
  type        = string
  default     = "1"
}

variable "cw_gt_comp_operator" {
  description = "A string of the description of comparator operator"
  type        = string
  default     = "GreaterThanOrEqualToThreshold"
}

variable "cw_lt_comp_operator" {
  description = "A string of the description of comparator operator"
  type        = string
  default     = "LessThanOrEqualToThreshold"
}

variable "cw_mem_unit" {
  description = "A string of the type of rds cloudwatch memory unit"
  type        = string
  default     = "Bytes"
}

variable "cw_mem_threshold" {
  description = "A string of the number of database cloudwatch memory threshold"
  type        = string
  default     = "100000000"
}

variable "cw_conn_unit" {
  description = "A string of the number of rds cloudwatch database connections"
  type        = string
  default     = "Count"
}

variable "cw_conn_threshold" {
  description = "A string of the number of database cloudwatch connection threshold"
  type        = string
  default     = "250"
}

variable "cw_rds_event_namespace" {
  description = "A string of the cloudwatch metric alarm namespace"
  type        = string
  default     = "AWS/Events"
}

variable "cw_rds_event_statistic" {
  description = "A string of the type of cloudwatch metric statistic"
  type        = string
  default     = "Sum"
}

variable "NETFLEX_RDS_MASTER_USR" {}
variable "NETFLEX_RDS_MASTER_PSW" {}

variable "alert_funnel_arn" {
  description = "The SNS Topic to send alerts to the funnel"
  type        = list(string)
}

variable "alert_funnel_app_name" {
  description = "A string for the alert funnel app name needed for funnel to operate"
  type        = string
  default     = "network-flex"
}

variable "vpc_tfstate_bucket" {
  description = "A string with the name of the bucket containing VPC tfstate file"
  type        = string
}

variable "vpc_tfstate_key" {
  description = "A string with the name of the key for VPC tfstate file"
  type        = string
}

