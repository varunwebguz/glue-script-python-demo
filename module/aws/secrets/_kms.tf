# TODO :: this should be moved to base
resource "aws_kms_key" "netflex_master_secret_key" {
  deletion_window_in_days = 7
  description             = "CMK for netflex dashboard master secrets"
  enable_key_rotation     = true
  is_enabled              = true
  policy                  = <<EOF
  {
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow access for Key Administrators",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/"
        },
      "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/HPNNETFLEXJENKINSDEPLOY"
        },
      "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
        ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/HPNNETFLEXJENKINSDEPLOY"
      },
      "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
      "Resource": "*",
      "Condition": {
      "Bool": {
          "kms:GrantIsForAWSResource": "true"
          }
        }
      }
    ]
  }
  EOF
  tags                    = var.test_tags
}

resource "aws_kms_alias" "netflex_master_secret_key_alias" {
  name          = "alias/netflex-hpn-master-secrets"
  target_key_id = aws_kms_key.netflex_master_secret_key.id
}
