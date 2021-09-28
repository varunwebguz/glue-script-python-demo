resource "aws_glue_connection" "netflex_rds_connection" {
  connection_properties = {}
  name                  = "netflex_rds_connection"
  connection_type       = "NETWORK"
  physical_connection_requirements {
    availability_zone      = "us-east-1a"
    security_group_id_list = [data.aws_security_group.netflex_aurora_sg.id]
    subnet_id              = data.terraform_remote_state.remote-vpc.outputs.subnets[0]["id"]
  }
}
