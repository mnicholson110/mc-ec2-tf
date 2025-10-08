variable "name_prefix" {
  description = "Name/Project prefix for tags"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone in which to create the EBS volume"
  type        = string
}

variable "size_gb" {
  description = "EBS volume size (GiB)"
  type        = number
}

variable "type" {
  description = "EBS volume type"
  type        = string
}

