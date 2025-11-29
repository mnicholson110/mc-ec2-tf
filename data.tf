locals {
  tags = {
    Project = var.name_prefix
  }
  selected_vpc_id = data.aws_vpc.default.id
  # Prefer default public subnets in the default VPC; fall back to any if none found
  selected_subnet_id = length(data.aws_subnets.public_default.ids) > 0 ? data.aws_subnets.public_default.ids[0] : (
    length(data.aws_subnets.in_vpc.ids) > 0 ? data.aws_subnets.in_vpc.ids[0] : ""
  )
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "in_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Default public subnets (map-public-ip-on-launch + default-for-az)
data "aws_subnets" "public_default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

data "aws_subnet" "selected" {
  id = local.selected_subnet_id
}

# Latest AL2023 arm64 AMI via SSM Parameter
data "aws_ssm_parameter" "al2023_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}
