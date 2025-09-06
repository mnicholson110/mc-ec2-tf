locals {
  tags = {
    Project = var.name_prefix
  }
  # Resolve VPC/subnet: prefer explicit vars; otherwise fall back to default VPC and its first subnet
  selected_vpc_id    = var.vpc_id != "" ? var.vpc_id : try(data.aws_vpc.default.id, "")
  selected_subnet_id = var.subnet_id != "" ? var.subnet_id : (length(try(data.aws_subnets.in_vpc.ids, [])) > 0 ? data.aws_subnets.in_vpc.ids[0] : "")
}

# Auto-discovery helpers (only used if vars are blank)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "in_vpc" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default.id]
  }
}

# Modules
module "image_builder" {
  source              = "./modules/image_builder"
  name_prefix         = var.name_prefix
  vpc_id              = local.selected_vpc_id
  subnet_id           = local.selected_subnet_id
  root_volume_size_gb = var.root_volume_size_gb
}

module "launch_template" {
  source                 = "./modules/launch_template"
  name_prefix            = var.name_prefix
  vpc_id                 = local.selected_vpc_id
  subnet_id              = local.selected_subnet_id
  ami_id                 = module.image_builder.ami_id
  instance_type          = var.instance_type
  associate_public_ip    = var.associate_public_ip
  key_name               = var.key_name
  monitoring_enabled     = var.monitoring_enabled
  root_volume_size_gb    = var.root_volume_size_gb
  allowed_cidr           = var.allowed_cidr

  mc_version                  = var.mc_version
  java_heap                   = var.java_heap
  view_distance               = var.view_distance
  simulation_distance         = var.simulation_distance
  whitelist                   = var.whitelist
  enable_command_block        = var.enable_command_block
  enable_rcon                 = var.enable_rcon
  server_properties_overrides = var.server_properties_overrides
  ops_usernames               = var.ops_usernames
  whitelist_usernames         = var.whitelist_usernames
}

module "ec2_instance" {
  source            = "./modules/ec2_instance"
  name_prefix       = var.name_prefix
  launch_template_id = module.launch_template.launch_template_id
}
