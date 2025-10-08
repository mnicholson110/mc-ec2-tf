variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "monitoring_enabled" { type = bool }
variable "root_volume_size_gb" { type = number }
variable "allowed_cidr" { type = string }

# Minecraft tunables
variable "mc_version" { type = string }
variable "java_heap" { type = string }
variable "view_distance" { type = number }
variable "simulation_distance" { type = number }
variable "whitelist" { type = bool }
variable "enable_command_block" { type = bool }
variable "enable_rcon" { type = bool }
variable "server_properties_overrides" { type = map(string) }

variable "ops_usernames" { type = list(string) }
variable "whitelist_usernames" { type = list(string) }

# Data volume attach/mount
variable "data_volume_id" { type = string }
variable "data_volume_device_name" { type = string }
