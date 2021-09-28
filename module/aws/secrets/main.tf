terraform {
  backend "s3" {}
  required_providers {
    aws = "~> 2.70"
  }
}

locals {
  name = "${var.app_prefix}-${var.asset_name}"
  rotation_detail = {
    engine   = "postgres"
    host     = data.aws_rds_cluster.networkflex_aurora_cluster.endpoint
    username = var.SCO_RDS_MASTER_USR
    password = var.SCO_RDS_MASTER_PSW
    dbname   = "sco_db"
    port     = "5432"
  }

}