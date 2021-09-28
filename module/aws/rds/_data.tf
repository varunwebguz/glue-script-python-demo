data "aws_caller_identity" "current" {
}

data "template_file" "networkflex_aurora_key_policy" {
  template = file("${path.module}/key_policy.tmpl")
  vars = {
    kms_accounts = jsonencode([
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
    ])
    kms_key_administrators = jsonencode([
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/HPNNETFLEXJENKINSDEPLOY"
    ])
    kms_key_users = jsonencode([
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/HPNNETFLEXJENKINSDEPLOY"
    ])
  }
}
data "template_file" "networkflex_master_secret_key_policy" {
  template = file("${path.module}/key_policy.tmpl")
  vars = {
    kms_accounts = jsonencode([
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
    ])
    kms_key_administrators = jsonencode([
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/HPNNETFLEXJENKINSDEPLOY"
    ])
    kms_key_users = jsonencode([
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/HPNNETFLEXJENKINSDEPLOY"
    ])
  }
}

data "terraform_remote_state" "remote-vpc" {
  backend = "s3"
  config = {
    bucket  = "${var.vpc_tfstate_bucket}"
    key     = "${var.vpc_tfstate_key}"
    region  = "us-east-1"
    profile = "saml"
  }
}


#data "aws_security_group" "networkflex_aurora_sg" {
#  name = "sco-networkflex-aurora-${var.environment}-sg"
#}
