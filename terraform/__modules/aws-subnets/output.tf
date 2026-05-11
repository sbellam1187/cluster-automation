output "subnet_id" {
  description = "subnet id"
  value       = { for k, v in aws_subnet.this : k => v.id }
}
