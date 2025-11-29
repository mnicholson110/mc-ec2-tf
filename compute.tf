resource "aws_iam_role" "mc" {
  name = "${var.name_prefix}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.mc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "mc" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.mc.name
  tags = local.tags
}

resource "aws_instance" "mc" {
  count         = var.instance_count
  ami           = data.aws_ssm_parameter.al2023_arm64.value
  instance_type = var.instance_type

  subnet_id                   = local.selected_subnet_id
  vpc_security_group_ids      = [aws_security_group.mc.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.mc.name

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/userdata.sh.tftpl", {
    mc_version                       = "1.21.10"
    java_heap                        = "2G"
    view_distance                    = 10
    simulation_distance              = 8
    whitelist                        = var.whitelist
    enable_command_block             = false
    enable_rcon                      = false
    server_properties_overrides_json = jsonencode({})
    ops_usernames_json               = jsonencode([])
    whitelist_usernames_json         = jsonencode(var.whitelist_usernames)
    data_volume_id                   = aws_ebs_volume.data.id
    data_volume_device_name          = "/dev/sdf"
  })

  # Ensure user_data changes trigger instance replacement so cloud-init re-runs
  user_data_replace_on_change = true

  tags = merge(local.tags, { Name = "${var.name_prefix}-srv" })
}

resource "aws_security_group" "mc" {
  name        = "${var.name_prefix}-sg"
  description = "Minecraft server SG"
  vpc_id      = local.selected_vpc_id

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
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_ebs_volume" "data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = 30
  type              = "gp3"

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-data"
  })
}

resource "aws_volume_attachment" "data" {
  count                          = var.instance_count == 1 ? 1 : 0
  device_name                    = "/dev/sdf"
  volume_id                      = aws_ebs_volume.data.id
  instance_id                    = aws_instance.mc[0].id
  stop_instance_before_detaching = true
  force_detach                   = false
}

resource "aws_eip" "static" {
  count  = 1
  domain = "vpc"
  tags = {
    Name    = "${var.name_prefix}-eip"
    Project = var.name_prefix
  }
}

resource "aws_eip_association" "mc" {
  count         = var.instance_count == 1 && try(aws_eip.static[0].id, "") != "" ? 1 : 0
  allocation_id = aws_eip.static[0].id
  instance_id   = aws_instance.mc[0].id
}
