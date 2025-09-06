output "volume_id" {
  description = "ID of the created EBS volume"
  value       = aws_ebs_volume.this.id
}
