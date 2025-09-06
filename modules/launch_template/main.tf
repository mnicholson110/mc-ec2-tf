locals {
  tags = {
    Project = var.name_prefix
  }
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Security group for runtime instance
resource "aws_security_group" "mc" {
  name        = "${var.name_prefix}-sg"
  description = "Minecraft SG"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Minecraft"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  tags = local.tags
}

resource "aws_iam_role" "mc" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.mc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Inline policy to allow attaching the persistent data EBS volume from user-data
resource "aws_iam_role_policy" "ec2_attach_volume" {
  count = var.data_volume_enabled ? 1 : 0
  name  = "${var.name_prefix}-ec2-attach-volume"
  role  = aws_iam_role.mc.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:AttachVolume", "ec2:DescribeVolumes", "ec2:DescribeInstances"]
        Resource = "*"
      }
    ]
  })
}

 

# Inline policy to allow associating/disassociating a pre-allocated Elastic IP
resource "aws_iam_role_policy" "ec2_manage_eip" {
  count = var.eip_enabled ? 1 : 0
  name  = "${var.name_prefix}-ec2-manage-eip"
  role  = aws_iam_role.mc.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress",
          "ec2:DescribeAddresses",
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "mc" {
  name = "${var.name_prefix}-ec2-prof"
  role = aws_iam_role.mc.name
}

resource "aws_launch_template" "mc" {
  name_prefix            = "${var.name_prefix}-lt-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  update_default_version = true
  key_name               = var.key_name != "" ? var.key_name : null

  credit_specification {
    cpu_credits = "unlimited"
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip
    delete_on_termination       = true
    subnet_id                   = var.subnet_id
    private_ip_address          = var.private_ip_address != "" ? var.private_ip_address : null
    security_groups             = [aws_security_group.mc.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size_gb
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.mc.name
  }

  monitoring {
    enabled = var.monitoring_enabled
  }

  metadata_options {
    http_tokens = "required"
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh.tftpl", {
    name_prefix                       = var.name_prefix
    mc_version                         = var.mc_version
    java_heap                          = var.java_heap
    view_distance                      = var.view_distance
    simulation_distance                = var.simulation_distance
    whitelist                          = var.whitelist
    enable_command_block               = var.enable_command_block
    enable_rcon                        = var.enable_rcon
    ops_usernames_json                 = jsonencode(var.ops_usernames)
    whitelist_usernames_json           = jsonencode(var.whitelist_usernames)
    server_properties_overrides_json   = jsonencode(var.server_properties_overrides)
    data_volume_enabled                = var.data_volume_enabled
    data_volume_id                     = var.data_volume_id
    data_volume_device_name            = var.data_volume_device_name

    eip_enabled                        = var.eip_enabled
    eip_allocation_id                  = var.eip_allocation_id
  }))

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { Name = "${var.name_prefix}-srv" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  tags = local.tags
}
