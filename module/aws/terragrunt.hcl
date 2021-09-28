generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  version = "~> 3.0"
  region = "us-east-1"
  profile = "saml"
}
EOF
}


remote_state {
  backend = "s3"
  config = {
    bucket         = "test-tf-state-${get_env("TF_VAR_account_number", "461894682041")}"
    dynamodb_table = "test-tf-lock-${get_env("TF_VAR_account_number", "461894682041")}"
    key            = "terraform/netflex/${get_env("TF_VAR_env")}/${path_relative_to_include()}/tfstate"
    profile        = "saml"
    region         = "us-east-1"
  }
}