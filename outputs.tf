output "ami_id" {
  description = "Baked AMI ID"
  value       = module.image_builder.ami_id
}

output "instance_ids" {
  description = "Managed EC2 instance IDs"
  value       = module.ec2_instance.instance_ids
}

output "data_volume_id" {
  description = "Persistent EBS data volume ID"
  value       = try(module.ebs_data[0].volume_id, null)
}

output "eip_public_ip" {
  description = "Elastic IP address (if allocated by Terraform)"
  value       = try(aws_eip.static[0].public_ip, null)
}

output "launch_template_latest_version" {
  description = "Launch template latest version"
  value       = module.launch_template.launch_template_latest_version
}

output "instance_private_ips" {
  description = "Private IP addresses of managed instances"
  value       = module.ec2_instance.private_ips
}

output "instance_public_ips" {
  description = "Public IP addresses of managed instances"
  value       = module.ec2_instance.public_ips
}
