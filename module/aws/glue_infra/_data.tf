data "terraform_remote_state" "remote-vpc" {
  backend = "s3"
  config = {
    bucket  = var.vpc_tfstate_bucket
    key     = var.vpc_tfstate_key
    region  = "us-east-1"
    profile = "saml"
  }
}

data "aws_secretsmanager_secret" "netflex_master_secret" {
  name = "netflex-rds-master"
}

data "aws_secretsmanager_secret_version" "rds_master_secret_map" {
  secret_id = data.aws_secretsmanager_secret.netflex_master_secret.id
}

#data "local_file" "app_version" {
#    filename = "./product.version"
#}

data "aws_rds_cluster" "rxcdc_aurora_cluster" {
  cluster_identifier = "netflex-hpn-aurora-cluster"
}

data "aws_security_group" "netflex_aurora_sg" {
  filter {
    name   = "group-name"
    values = [var.security_group_id]
  }

  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.remote-vpc.outputs.vpc.id]
  }

}
