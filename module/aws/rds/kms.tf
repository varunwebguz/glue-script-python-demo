resource "aws_kms_key" "networkflex_aurora_key" {
  deletion_window_in_days = 7
  description             = "CMK for postgresql aurora cluster"
  enable_key_rotation     = true
  is_enabled              = true
  policy                  = data.template_file.networkflex_aurora_key_policy.rendered
  tags                    = var.test_tags
}
resource "aws_kms_alias" "networkflex_aurora_key_alias" {
  name          = "alias/netflex-aurora-${var.environment}"
  target_key_id = aws_kms_key.networkflex_aurora_key.id
}
resource "aws_kms_key" "networkflex_master_secret_key" {
  deletion_window_in_days = 7
  description             = "CMK for networkflex master secrets"
  enable_key_rotation     = true
  is_enabled              = true
  policy                  = data.template_file.networkflex_master_secret_key_policy.rendered
  tags                    = var.test_tags
}
resource "aws_kms_alias" "networkflex_master_secret_key_alias" {
  name          = "alias/netflex-master-secrets-${var.environment}"
  target_key_id = aws_kms_key.networkflex_master_secret_key.id
}
