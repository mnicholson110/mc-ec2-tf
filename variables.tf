variable "region" {
  description = "AWS region"
  type        = string
}

variable "name_prefix" {
  description = "Name tag / prefix for resources"
  type        = string
  default     = "minecraft"
}

variable "instance_type" {
  description = "EC2 instance type for the Minecraft server"
  type        = string
  default     = "t4g.medium"
}

variable "instance_count" {
  description = "Number of EC2 instances to launch (set to 0 to stop)"
  type        = number
  default     = 1
  validation {
    condition     = var.instance_count >= 0 && var.instance_count <= 1
    error_message = "instance_count must be 0 or 1."
  }
}

variable "whitelist" {
  description = "Enable Minecraft whitelist (enforce-whitelist)"
  type        = bool
  default     = true
}

variable "whitelist_usernames" {
  description = "Usernames to include in whitelist.json on first boot (leave empty to preserve existing whitelist.json on the data volume)."
  type        = list(string)
  default     = []
}
