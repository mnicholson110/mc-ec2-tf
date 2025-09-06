output "ami_id" {
  description = "Baked AMI ID"
  value       = module.image_builder.ami_id
}

output "asg_name" {
  description = "Auto Scaling group name"
  value       = module.asg.name
}

output "instance_ids" {
  description = "Instance IDs in the ASG (running)"
  value       = data.aws_instances.mc.ids
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
