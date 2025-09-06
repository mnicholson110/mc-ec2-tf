variable "name_prefix" { type = string }
variable "launch_template_id" { type = string }
variable "launch_template_version" { type = string }

variable "min_size" { type = number }
variable "max_size" { type = number }
variable "desired_capacity" { type = number }

variable "health_check_type" {
  type    = string
  default = "EC2"
}

variable "health_check_grace_period" {
  type    = number
  default = 300
}

variable "termination_policies" {
  type    = list(string)
  default = ["Default"]
}

variable "instance_warmup" {
  type    = number
  default = 60
}

variable "min_healthy_percentage" {
  type    = number
  default = 0
}

