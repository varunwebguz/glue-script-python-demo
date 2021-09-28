include {
  path = find_in_parent_folders()
}

terraform {
  extra_arguments "publish_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh",
      "output",
      "destroy"
    ]
    arguments = [
      "-var", "environment=${get_env("TF_VAR_env")}",
    ]
    required_var_files = [
      "${get_parent_terragrunt_dir()}/common.tfvars",
      "${get_terragrunt_dir()}/env-config/${get_env("TF_VAR_region", "us-east-1")}/${get_env("TF_VAR_env")}.tfvars"
    ]
  }
}
