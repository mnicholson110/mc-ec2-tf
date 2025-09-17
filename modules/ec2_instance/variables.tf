variable "name_prefix" {
  description = "Name prefix for tagging the instance"
  type        = string
}

variable "launch_template_id" {
  description = "Launch template ID used to provision the instance"
  type        = string
}

variable "launch_template_version" {
  description = "Launch template version to use (e.g. \"1\", \"$Latest\", or \"$Default\")"
  type        = string
  default     = "$Latest"
}

variable "instance_count" {
  description = "Number of EC2 instances to manage (set to 0 to disable)"
  type        = number
  default     = 0
  validation {
    condition     = var.instance_count >= 0 && var.instance_count <= 1
    error_message = "instance_count must be 0 or 1 for this module."
  }
}

variable "data_volume_enabled" {
  description = "Whether to attach the persistent data volume"
  type        = bool
  default     = false
}

variable "data_volume_id" {
  description = "Persistent data volume ID to attach"
  type        = string
  default     = ""
}

variable "data_volume_device_name" {
  description = "Device name to expose the persistent data volume"
  type        = string
  default     = "/dev/sdf"
}

variable "eip_enabled" {
  description = "Whether to associate an Elastic IP"
  type        = bool
  default     = false
}

variable "eip_allocation_id" {
  description = "Elastic IP allocation ID to associate"
  type        = string
  default     = ""
}
