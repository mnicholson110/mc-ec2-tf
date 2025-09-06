locals {
  tags = {
    Project = var.name_prefix
  }
}

# Latest AL2023 arm64 AMI
data "aws_ssm_parameter" "al2023_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

# Egress-only SG for Image Builder build instance
resource "aws_security_group" "ib" {
  name        = "${var.name_prefix}-ib-sg"
  description = "Egress-only SG for AMI builds"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# Roles and profile for build instance
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ib_instance" {
  name               = "${var.name_prefix}-ib-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ib_ssm" {
  role       = aws_iam_role.ib_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ib_profile" {
  role       = aws_iam_role.ib_instance.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_iam_instance_profile" "ib" {
  name = "${var.name_prefix}-ib-instance-profile"
  role = aws_iam_role.ib_instance.name
}

resource "aws_imagebuilder_infrastructure_configuration" "mc" {
  name                          = "${var.name_prefix}-ib-infra"
  instance_profile_name         = aws_iam_instance_profile.ib.name
  subnet_id                     = var.subnet_id
  security_group_ids            = [aws_security_group.ib.id]
  terminate_instance_on_failure = true
  tags                          = local.tags
}

resource "aws_imagebuilder_component" "mc_base" {
  name     = "${var.name_prefix}-component"
  platform = "Linux"
  version  = "1.0.2"
  data     = file("${path.module}/components/minecraft-base.yml")
  tags     = local.tags
}

resource "aws_imagebuilder_image_recipe" "mc" {
  name         = "${var.name_prefix}-recipe"
  version      = "1.0.1"
  parent_image = data.aws_ssm_parameter.al2023_arm64.value

  component {
    component_arn = aws_imagebuilder_component.mc_base.arn
  }

  block_device_mapping {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size_gb
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tags = local.tags
}

resource "aws_imagebuilder_image" "mc" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.mc.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.mc.arn
  tags                             = local.tags
}

locals {
  baked_ami_id = try(element(tolist(aws_imagebuilder_image.mc.output_resources[0].amis), 0).image, null)
}

