output "instance_is_running" {
  description = "Is a server running?"
  value       = var.instance_count == 1 ? "Yes" : "No"
}
