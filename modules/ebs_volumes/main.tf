locals {
  tags = {
    Project = var.name_prefix
  }
}

resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone
  size              = var.size_gb
  type              = var.type

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-data"
  })
}

