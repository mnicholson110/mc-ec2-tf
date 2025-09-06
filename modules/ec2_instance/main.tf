locals {
  tags = {
    Project = var.name_prefix
  }
}

resource "aws_instance" "mc" {
  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  tags = merge(local.tags, { Name = "${var.name_prefix}-srv" })
}

