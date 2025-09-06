output "ami_id" {
  description = "Baked AMI ID"
  value       = module.image_builder.ami_id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2_instance.instance_id
}

output "public_ip" {
  description = "Public IP of the server"
  value       = module.ec2_instance.public_ip
}

output "connect" {
  description = "Minecraft connection string"
  value       = "${module.ec2_instance.public_ip}:25565"
}
