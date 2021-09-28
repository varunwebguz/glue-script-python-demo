# RDS Master
resource "aws_secretsmanager_secret" "sco-rds-master" {
  name        = "sco-rds-master"
  description = "RDS Master username and password"
  kms_key_id  = aws_kms_key.sco_master_secret_key.arn
  tags        = var.test_tags
  depends_on  = [aws_kms_key.sco_master_secret_key]
}

resource "aws_secretsmanager_secret_version" "sco-rds-master" {
  secret_id     = aws_secretsmanager_secret.sco-rds-master.id
  secret_string = jsonencode(local.rotation_detail)
}

resource "aws_secretsmanager_secret_rotation" "rotation_lambda" {
  secret_id           = aws_secretsmanager_secret.sco-rds-master.id
  rotation_lambda_arn = aws_lambda_function.rotation_lambda.arn

  rotation_rules {
    automatically_after_days = 30
  }
}
