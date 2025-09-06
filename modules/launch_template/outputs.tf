output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.mc.id
}

output "security_group_id" {
  description = "Security group ID for server ingress"
  value       = aws_security_group.mc.id
}

output "launch_template_latest_version" {
  description = "Launch template latest version"
  value       = aws_launch_template.mc.latest_version
}
