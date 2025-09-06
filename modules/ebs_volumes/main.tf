locals {
  tags = {
    Project = var.name_prefix
  }
}

resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone
  size              = var.size_gb
  type              = var.type
  iops              = var.type == "gp3" || var.type == "io2" || var.type == "io1" ? var.iops : null
  throughput        = var.type == "gp3" ? var.throughput : null

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-data"
  })
}

