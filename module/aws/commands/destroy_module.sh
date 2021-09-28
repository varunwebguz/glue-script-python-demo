#!/bin/bash
set -e -o pipefail

export MODULE_NAME="${1}"
export ENV="${2}"
export REGION="${3:-us-east-1}"

cd "$(dirname "${0}")/module/aws/commands" || true
source pre.sh
cd "../${MODULE_NAME}" || true

# tfenv converts all environment variables to TF_VAR's
# CAUTION: destroy set to interactive to avoiding accidentally destroy resources
source <(tfenv)
terragrunt destroy ${TFTG_CLI_ARGS_DESTROY_MODULE}
