locals {
  tags = {
    Project = var.name_prefix
  }
}

resource "aws_autoscaling_group" "mc" {
  name                      = "${var.name_prefix}-asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  # Do not set vpc_zone_identifier since subnet is pinned in the Launch Template

  termination_policies = var.termination_policies

  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup        = var.instance_warmup
      min_healthy_percentage = var.min_healthy_percentage
    }
    triggers = []
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-srv"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

