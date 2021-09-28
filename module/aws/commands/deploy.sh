#!/bin/bash
set -e -o pipefail

export ENV="${1:-local}"
export REGION="${2:-us-east-1}"

cd "$(dirname "${0}")/module/aws/commands" || true
source pre.sh
cd ".."

# Run Terragrunt to apply all infrastructure
echo "Running terragrunt for environment: ${ENV}"

# tfenv converts all environment variables to TF_VAR's
source <(tfenv)
terragrunt run-all apply ${TFTG_CLI_ARGS_DEPLOY}
