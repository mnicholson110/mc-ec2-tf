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

data "aws_subnet" "selected" {
  id = local.selected_subnet_id
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
  private_ip_address     = var.private_ip_address
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

  data_volume_enabled     = var.data_volume_enabled
  data_volume_id          = try(module.ebs_data[0].volume_id, "")
  data_volume_device_name = var.data_volume_device_name

  eip_enabled       = var.eip_enabled
  eip_allocation_id = var.eip_allocation_id != "" ? var.eip_allocation_id : try(aws_eip.static[0].id, "")
}

module "asg" {
  source                  = "./modules/autoscaling_group"
  name_prefix             = var.name_prefix
  launch_template_id      = module.launch_template.launch_template_id
  launch_template_version = var.asg_launch_template_version

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity
}

# Discover running instances for convenience outputs (may be empty when desired=0)
data "aws_instances" "mc" {
  instance_tags = {
    Name = "${var.name_prefix}-srv"
  }
  instance_state_names = ["running"]
  depends_on = [module.asg]
}

# Persistent data volume module (single, re-attached across instance replacements)
module "ebs_data" {
  count             = var.data_volume_enabled ? 1 : 0
  source            = "./modules/ebs_volumes"
  name_prefix       = var.name_prefix
  availability_zone = data.aws_subnet.selected.availability_zone
  size_gb           = var.data_volume_size_gb
  type              = var.data_volume_type
  iops              = var.data_volume_iops
  throughput        = var.data_volume_throughput
}

 

# Optional Elastic IP for stable public IP
resource "aws_eip" "static" {
  count = var.eip_enabled && var.eip_allocation_id == "" ? 1 : 0
  domain = "vpc"
  tags = {
    Name    = "${var.name_prefix}-eip"
    Project = var.name_prefix
  }
}
