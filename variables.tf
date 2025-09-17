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

variable "private_ip_address" {
  description = "Optional fixed private IPv4 to assign to the instance's primary interface. Must be within the selected subnet and free at launch."
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


# ---- Runtime EC2 instance management ----
variable "instance_count" {
  description = "Number of EC2 instances to launch (set to 0 to disable)"
  type        = number
  default     = 0
  validation {
    condition     = var.instance_count >= 0 && var.instance_count <= 1
    error_message = "instance_count must be 0 or 1."
  }
}

# Explicit launch template version used for the managed instance(s).
# Accepts a numeric version (e.g., "1") or special values like "$Latest" or "$Default".
variable "instance_launch_template_version" {
  description = "Launch template version for the managed instances (e.g., \"1\", \"$Latest\", or \"$Default\")."
  type        = string
  default     = "$Latest"
}

# ---- Persistent data volume ----
variable "data_volume_enabled" {
  description = "Create and attach a persistent EBS volume for /opt/minecraft"
  type        = bool
  default     = true
}

variable "data_volume_size_gb" {
  description = "Data volume size (GiB)"
  type        = number
  default     = 40
}

variable "data_volume_type" {
  description = "EBS volume type for data disk"
  type        = string
  default     = "gp3"
}

variable "data_volume_iops" {
  description = "IOPS for gp3/io1/io2 volumes (optional)"
  type        = number
  default     = 3000
}

variable "data_volume_throughput" {
  description = "Throughput (MiB/s) for gp3 volumes (optional)"
  type        = number
  default     = 125
}

variable "data_volume_device_name" {
  description = "Linux device name to attach the data volume as (kernel may remap to NVMe)"
  type        = string
  default     = "/dev/sdf"
}





# ---- Optional Elastic IP (stable public IP) ----
variable "eip_enabled" {
  description = "Allocate and associate an Elastic IP to the instance at boot for a stable public IP"
  type        = bool
  default     = false
}

variable "eip_allocation_id" {
  description = "Optional existing EIP allocation ID to use. Leave blank to have Terraform allocate one when eip_enabled is true."
  type        = string
  default     = ""
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
