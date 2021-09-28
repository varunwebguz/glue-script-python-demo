test_tags = {
  AsaqId                 = "ASAQ-2601948"
  AppName                = "networkFlexApplication"
  AssetName              = "test-us-da-hpp-dev"
  AssetOwner             = "Ankur.Agarwal@test.com"
  BackupOwner            = "srinivasa.chary@test.com"
  CiId                   = "notAssigned"
  CostCenter             = "500014L3"
  Environment            = "dev"
  Purpose                = "Deploy claim glue jobs"
  Team                   = "RXI-CDC"
  Version                = "0.0.1"
  DataSubjectArea        = "pharmacy"
  ComplianceDataCategory = "none"
  DataClassification     = "proprietary"
}

db_iam_roles       = []
environment        = "dev"
vpc_tfstate_bucket = "test-tf-state-461894682041"
vpc_tfstate_key    = "terraform/hpnnetflex/dev/hpn-netflex-base-infra/tfstate"
#database_name      = "netflex"
port = "5432"

# GLUE JOB NAMES
glue_netflex_claim_deploy_job = "cdc_netflex_claim_deploy_job"

# GLUE ONDEMAND TRIGGER NAMES
glue_netflex_claim_deploy_trigger = "cdc_netflex_claim_deploy_trigger"
glue_role_arn                   = "arn:aws:iam::461894682041:role/Enterprise/NETFLEXETLGLUE"
artifacts_bucket                = "cdc-da-hpn-net-flex-artifacts-dev"
aws_glue_connection             = ["netflex_rds_connection"]

netflex_glueclaim_config = {
  secret_name          = "netflex-rds-master"
  region_name          = "us-east-1"
  dbname               = "netflex"
  port                 = "5432"
  artifacts_bucket     = "cdc-da-hpn-net-flex-artifacts-dev"
  artifacts_bucket_key = "hpn-netflex-dataservices/claim"
  ddl_version          = "ver0"
}

security_group_id = "netflex-hpn-aurora-dev-sg"

app_prefix       = "netflex"
alert_funnel_arn = ["arn:aws:sns:us-east-1:929468956630:cloudwatch-alarm-funnel"]
#splunk_destination_arn     = "arn:aws:logs:us-east-1:746770431074:destination:CentralizedLogging-v2-Destination"

# 360 settings
config_360 = {
    db_host_360 = "da-ent360-views-redshift-cluster-ra3-dev.csy0gkop8fp9.us-east-1.redshift.amazonaws.com"
    db_name_360 = "da_ent360_ra3_db_dev"
    db_user_360 = "extract_smprerx_user"
    db_port_360 = "5439"
    cluster_id_360 = "da-ent360-views-redshift-cluster-ra3-dev"
    assumed_rolearn_360 = "arn:aws:iam::302619437920:role/Enterprise/SMPRERXTEAM"
    #s3_bucket_360 = "da-datastore-enterprise-360-raw.dev-testsplithorizon"
	  s3_bucket_360 = "cdc-da-rx-logs-dev"
	  database = "da_ent360_ra3_db_dev"
	  redshift_cluster_name = "da-ent360-views-redshift-cluster-ra3-dev"
}