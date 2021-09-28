resource "aws_security_group" "networkflex_aurora_sg" {
  name        = "netflex-hpn-aurora-${var.environment}-sg"
  description = "Allow inbound traffic to the netflex Aurora cluster"
  vpc_id      = data.terraform_remote_state.remote-vpc.outputs.vpc.id

  ingress = [
    {
      from_port        = "${var.port}"
      to_port          = "${var.port}"
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/8"]
      description      = "HTTP"
      ipv6_cidr_blocks = [],
      prefix_list_ids  = [],
      security_groups  = [],
      self             = false

    },
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      description      = "Self Referencing Rule"
      ipv6_cidr_blocks = [],
      prefix_list_ids  = [],
      security_groups  = [],
      self             = true

    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["10.0.0.0/8"]
      description      = "Outbound"
      ipv6_cidr_blocks = [],
      prefix_list_ids  = [],
      security_groups  = [],
      self             = false
    },
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      description      = "Self Referencing Rule"
      ipv6_cidr_blocks = [],
      prefix_list_ids  = [],
      security_groups  = [],
      self             = true
    },
    {
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = []
      description      = "S3 access through endpoint"
      ipv6_cidr_blocks = [],
      prefix_list_ids  = ["pl-63a5400a"],
      security_groups  = [],
      self             = false
    }
  ]

  tags = merge(
    var.test_tags,
    map(
      "Name", "netflex-hpn-aurora-${var.environment}-sg",
      "AssetName", "netflex Aurora security group",
      "Purpose", "Control access to / from netflex  Aurora cluster"
    )
  )
}