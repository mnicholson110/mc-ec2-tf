output "instance_ids" {
  description = "IDs of the managed EC2 instances"
  value       = aws_instance.mc[*].id
}

output "private_ips" {
  description = "Private IPs of the managed instances"
  value       = aws_instance.mc[*].private_ip
}

output "public_ips" {
  description = "Public IPs of the managed instances"
  value       = aws_instance.mc[*].public_ip
}
