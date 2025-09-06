output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.mc.id
}

output "public_ip" {
  description = "Public IP of the server"
  value       = aws_instance.mc.public_ip
}

