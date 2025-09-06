variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC to use for both Image Builder and the runtime instance. Leave blank to auto-detect the default VPC."
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet for runtime EC2 (public or private with NAT). Leave blank to auto-pick a subnet in the selected VPC."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type for the Minecraft server"
  type        = string
  default     = "t4g.medium"
}

variable "associate_public_ip" {
  description = "Associate a public IP to the instance's primary network interface"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Optional EC2 key pair name to attach for SSH access (leave blank to omit)"
  type        = string
  default     = ""
}

variable "monitoring_enabled" {
  description = "Enable detailed monitoring for the instance"
  type        = bool
  default     = true
}


variable "root_volume_size_gb" {
  description = "Root EBS volume size (GiB)"
  type        = number
  default     = 40
}


variable "allowed_cidr" {
  description = "CIDR allowed to connect to Minecraft (25565/TCP). Use your IP/CIDR or 0.0.0.0/0"
  type        = string
  default     = "0.0.0.0/0"
}


variable "name_prefix" {
  description = "Name tag / prefix for resources"
  type        = string
  default     = "minecraft"
}


# ---- Minecraft tunables rendered via user-data ----
variable "mc_version" {
  description = "Minecraft version to run with Paper"
  type        = string
  default     = "1.21.8"
}


variable "java_heap" {
  description = "Java heap size (e.g., 2G or 3G)."
  type        = string
  default     = "2G"
}

variable "view_distance" {
  type    = number
  default = 10
}


variable "simulation_distance" {
  type    = number
  default = 8
}


variable "whitelist" {
  type    = bool
  default = false
}


variable "enable_command_block" {
  type    = bool
  default = false
}


variable "enable_rcon" {
  type    = bool
  default = false
}

variable "server_properties_overrides" {
  description = "Map of server.properties overrides (key=value). Keys not present in the base template will be appended."
  type        = map(string)
  default     = {}
}

# ---- Initial access lists ----
variable "ops_usernames" {
  description = "Usernames to grant operator (level 4) access at first boot."
  type        = list(string)
  default     = []
}


variable "whitelist_usernames" {
  description = "Usernames to whitelist at first boot. Only used if whitelist is enabled."
  type        = list(string)
  default     = []
}
