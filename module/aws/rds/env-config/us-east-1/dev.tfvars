test_tags = {
  AsaqId                 = "ASAQ-2601948"
  AppName                = "networkFlexApplication"
  AssetName              = "test-us-da-hpp-dev"
  AssetOwner             = "Ankur.Agarwal@test.com"
  BackupOwner            = "sriharsha.valeti@test.com"
  CiId                   = "notAssigned"
  CostCenter             = "500014L3"
  Environment            = "dev"
  Purpose                = "Aurora cluster that houses netflex data"
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
database_name      = "netflex"
port               = "5432"


app_prefix       = "netflex"
alert_funnel_arn = ["arn:aws:sns:us-east-1:929468956630:cloudwatch-alarm-funnel"]
#splunk_destination_arn     = "arn:aws:logs:us-east-1:746770431074:destination:CentralizedLogging-v2-Destination"
aurora_instance_count = 2
rds_instance_class    = "db.t3.medium"
