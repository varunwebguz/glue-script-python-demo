#!/bin/bash
set -e -o pipefail

# returns the context of any active subroutine call
function caller_script() { 
  caller 1
}

# contains script name that sourced this script
PARENT_COMMAND_SCRIPT=$( basename $(echo $(caller_script) | cut -d " " -f3 ))

# initial setup and cleaning
function init {
    find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
    find . -type d -name ".terraform" -prune -exec rm -rf {} \;
}

# default commands for the terragrunt cli
DEFAULT_TFTG_CLI_ARGS="-no-color --terragrunt-non-interactive"
function setTfTgCliArguments() {
    export TFTG_CLI_ARGS_APPLY_MODULE="${DEFAULT_TFTG_CLI_ARGS} -auto-approve"
    export TFTG_CLI_ARGS_DEPLOY="${DEFAULT_TFTG_CLI_ARGS}"
    export TFTG_CLI_ARGS_DESTROY_MODULE="-no-color"
    export TFTG_CLI_ARGS_INIT_MODULE="${DEFAULT_TFTG_CLI_ARGS}"
    export TFTG_CLI_ARGS_PLAN_ALL="${DEFAULT_TFTG_CLI_ARGS}"
    export TFTG_CLI_ARGS_PLAN_MODULE="${DEFAULT_TFTG_CLI_ARGS}"
}

# parses aws-fed.toml for account number
function parse_toml() {
    # check wildq binary is installed else pip install
    if [[ ! $(wildq --version) ]]; then pip install wildq; fi

    # set MODULE path to find aws-fed-toml and parse
    export MODULE_ROOT_PATH=$(pwd |sed 's/plz-out.*//g')
    AWS_FED_TOML="${MODULE_ROOT_PATH}/third_party/aws_fed/aws-fed.toml"

    if [[ -f "${AWS_FED_TOML}" ]]; then
        export ACCOUNT_NUMBER=$(cat ${AWS_FED_TOML} | wildq --toml ".[\"${ENV}-deploy\"].account")
    else
        echo "No aws-fed.toml file found at ${AWS_FED_TOML} to parse for account id"
        exit 1
    fi
}

# checks if gatekeeper auth type has been configured
function auth_type() {
    if [[ "${AUTH_TYPE}" == "gatekeeper" ]]; then
        echo "[INFO] AUTH_TYPE set to gatekeeper"
        echo "[INFO] Checking for ACCOUNT_NUMBER..."
        if [[ -v ACCOUNT_NUMBER ]]; then
            echo "[INFO] Found ACCOUNT_NUMBER"
            export ACCOUNT_NUMBER=${ACCOUNT_NUMBER}
        else
            echo "[ERROR] Attempting to use the gatekeeper AUTH_TYPE but no ACCOUNT_NUMBER was provided. Exiting."
            exit 1
        fi
    else
        echo "[INFO] AUTH_TYPE set to federation"
        echo "[INFO] Parsing aws-fed.toml file for ACCOUNT_NUMBER"
        export AUTH_TYPE='federation'
        parse_toml
    fi
}

function set_and_fed() {
    setTfTgCliArguments
    auth_type

    # MODULE name is missing when running apply_all or plan_all
    if [ -z ${MODULE_NAME} ]; then MODULE_NAME="$(echo ${PARENT_COMMAND_SCRIPT^^} | sed 's/\.[^.]*$//')"; fi

    # set provider plugin cache to save at TF_PLUGIN_CACHE_DIR instead of having to re-download plugin providers. Commented out for now due to bug in terraform
    # export TF_PLUGIN_CACHE_DIR="/tmp/.terraform.d/plugin-cache/"
    # mkdir -p "${TF_PLUGIN_CACHE_DIR}"

    if [[ ! -v FED_PROVIDER ]]; then export FED_PROVIDER="CI"; fi

    # Federate and set terraform and terragrunt
    TERRAFORM_VERSION="${TERRAFORM_VERSION:-0.14.10}"
    TERRAGRUNT_VERSION="${TERRAGRUNT_VERSION:-0.28.19}"

    echo ""
    echo "[INFO] Environment       : ${ENV}"
    echo "[INFO] Account Id        : ${ACCOUNT_NUMBER}"
    echo "[INFO] Module Name       : ${MODULE_NAME}"
    echo "[INFO] AWS Region        : ${REGION}"
    echo "[INFO] Terraform Version : ${TERRAFORM_VERSION}"
    echo "[INFO] Terragrunt Version: ${TERRAGRUNT_VERSION}"
    echo "[INFO] Auth Type         : ${AUTH_TYPE}"
    echo "[INFO] Fed Provider      : ${FED_PROVIDER}"

    tfswitch "${TERRAFORM_VERSION}"
    #tgswitch --skip-lookup "${TERRAGRUNT_VERSION}"

    # Localhost federation process specified separately for Health Services and test users
    if [[ "${AUTH_TYPE}" == "federation" ]]; then
        echo ""
        if [[ "${FED_PROVIDER}" == "HS" ]]; then
            saml2aws login --skip-prompt; 
        else # ${FED_PROVIDER} == "CI" or empty
            aws-fed login "${ENV}-deploy" -f "${AWS_FED_TOML}";
        fi
    fi
}

case "${ENV}" in
  "dev")
    set_and_fed
    ;;
  "test")
    set_and_fed
    ;;
  "prod")
    set_and_fed
    ;;
  *)
    echo "${ENV} is not a valid environment. Terminating..."
    exit 1
    ;;
esac
