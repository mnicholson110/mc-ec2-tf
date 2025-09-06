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

variable "iops" {
  description = "IOPS for gp3/io1/io2 volumes (optional)"
  type        = number
  default     = 3000
}

variable "throughput" {
  description = "Throughput (MiB/s) for gp3 volumes (optional)"
  type        = number
  default     = 125
}

