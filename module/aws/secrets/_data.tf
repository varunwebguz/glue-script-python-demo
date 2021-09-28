data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


data "terraform_remote_state" "remote-vpc" {
  backend = "s3"
  config = {
    bucket  = "${var.vpc_tfstate_bucket}"
    key     = "${var.vpc_tfstate_key}"
    region  = "us-east-1"
    profile = "saml"
  }
}


data "aws_rds_cluster" "networkflex_aurora_cluster" {
  cluster_identifier = "netflex-hpn-aurora-cluster"
}

data "aws_security_group" "networkflex_aurora_sg" {
  filter {
    name   = "group-name"
    values = [var.security_group_id]
  }

  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.remote-vpc.outputs.vpc.id]
  }

}

