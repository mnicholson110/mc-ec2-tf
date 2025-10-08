locals {
  tags = {
    Project = var.name_prefix
  }
  selected_vpc_id    = data.aws_vpc.default.id
  selected_subnet_id = length(data.aws_subnets.in_vpc.ids) > 0 ? data.aws_subnets.in_vpc.ids[0] : ""
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

data "aws_subnet" "selected" {
  id = local.selected_subnet_id
}

# Modules
module "image_builder" {
  source              = "./modules/image_builder"
  name_prefix         = var.name_prefix
  vpc_id              = local.selected_vpc_id
  subnet_id           = local.selected_subnet_id
  root_volume_size_gb = 10
}

module "launch_template" {
  source              = "./modules/launch_template"
  name_prefix         = var.name_prefix
  vpc_id              = local.selected_vpc_id
  subnet_id           = local.selected_subnet_id
  ami_id              = module.image_builder.ami_id
  instance_type       = var.instance_type
  monitoring_enabled  = true
  root_volume_size_gb = 10
  allowed_cidr        = "0.0.0.0/0"

  mc_version                  = "1.21.8"
  java_heap                   = "2G"
  view_distance               = 10
  simulation_distance         = 8
  whitelist                   = var.whitelist
  enable_command_block        = false
  enable_rcon                 = false
  server_properties_overrides = {}
  ops_usernames               = []
  whitelist_usernames         = var.whitelist_usernames

  data_volume_id          = try(module.ebs_data[0].volume_id, "")
  data_volume_device_name = "/dev/sdf"
}

module "ec2_instance" {
  source                  = "./modules/ec2_instance"
  name_prefix             = var.name_prefix
  launch_template_id      = module.launch_template.launch_template_id
  launch_template_version = tostring(module.launch_template.launch_template_latest_version)
  instance_count          = var.instance_count
  data_volume_id          = try(module.ebs_data[0].volume_id, "")
  data_volume_device_name = "/dev/sdf"
  eip_allocation_id       = try(aws_eip.static[0].id, "")
}

module "ebs_data" {
  count             = 1
  source            = "./modules/ebs_volumes"
  name_prefix       = var.name_prefix
  availability_zone = data.aws_subnet.selected.availability_zone
  size_gb           = 30
  type              = "gp3"
}



resource "aws_eip" "static" {
  count  = 1
  domain = "vpc"
  tags = {
    Name    = "${var.name_prefix}-eip"
    Project = var.name_prefix
  }
}
