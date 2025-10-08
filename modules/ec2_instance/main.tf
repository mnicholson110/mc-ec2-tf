locals {
  tags = {
    Project = var.name_prefix
  }
}

resource "aws_instance" "mc" {
  count = var.instance_count

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  # this is managed by LT above
  lifecycle {
    ignore_changes = [user_data]
  }

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-srv"
  })
}

locals {
  primary_instance_id = try(aws_instance.mc[0].id, null)
}

resource "aws_volume_attachment" "data" {
  count       = var.instance_count == 1 && var.data_volume_id != "" ? 1 : 0
  device_name = var.data_volume_device_name
  volume_id   = var.data_volume_id
  instance_id = local.primary_instance_id
}

resource "aws_eip_association" "mc" {
  count         = var.instance_count == 1 && var.eip_allocation_id != "" ? 1 : 0
  allocation_id = var.eip_allocation_id
  instance_id   = local.primary_instance_id
}
