variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Image Builder infra"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Image Builder infra"
  type        = string
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size (GiB) for the built AMI"
  type        = number
}

