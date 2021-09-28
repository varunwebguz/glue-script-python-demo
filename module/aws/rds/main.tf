terraform {
  backend "s3" {}
}
resource "aws_db_subnet_group" "networkflex_aurora" {
  name       = "netflex-hpn-aurora-sng"
  subnet_ids = data.terraform_remote_state.remote-vpc.outputs.subnets.*.id
  tags = merge(
    map(
      "Name", "hpnnetflex Aurora DB subnet group"
    ),
    var.test_tags
  )
}
resource "aws_rds_cluster_parameter_group" "hpn_netflex_aurora" {
  name        = "networkflex-hpn-aurora-cluster-params"
  family      = "aurora-postgresql11"
  description = "hpn default parameter group"
}
resource "aws_rds_cluster" "networkflex_aurora_cluster" {
  cluster_identifier                  = "netflex-hpn-aurora-cluster"
  engine                              = var.rds_engine
  engine_version                      = var.rds_engine_version
  engine_mode                         = var.rds_engine_mode
  availability_zones                  = ["us-east-1a", "us-east-1b"]
  database_name                       = var.database_name
  master_username                     = var.NETFLEX_RDS_MASTER_USR
  master_password                     = var.NETFLEX_RDS_MASTER_PSW
  backup_retention_period             = 30
  preferred_backup_window             = "07:00-09:00"
  final_snapshot_identifier           = "netflex-hpn-aurora-snapshot-FINAL"
  copy_tags_to_snapshot               = true
  db_subnet_group_name                = aws_db_subnet_group.networkflex_aurora.name
  vpc_security_group_ids              = [aws_security_group.networkflex_aurora_sg.id]
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.networkflex_aurora_key.arn
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  iam_database_authentication_enabled = true
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.hpn_netflex_aurora.name
  apply_immediately                   = var.apply_immediately
  deletion_protection                 = true
  tags                                = merge(var.test_tags, var.additional_tags)
  # iam_roles                           = var.db_iam_roles
  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "networkflex_instances" {
  count                = var.rds_instance_count
  identifier           = "netflex-networkflex-aurora-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.networkflex_aurora_cluster.id
  instance_class       = var.rds_instance_class
  engine               = var.rds_engine
  engine_version       = var.rds_engine_version
  apply_immediately    = var.apply_immediately
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.networkflex_aurora.name
  tags = merge(
    var.test_tags, var.additional_tags
  )
}
