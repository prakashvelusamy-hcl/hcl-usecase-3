output "public_instance_ids" {
  description = "List of EC2 instance IDs for public instances"
  value       = aws_instance.public_instances[*].id
}

output "public_instance_ips" {
  description = "List of public IP addresses for the public instances"
  value       = aws_instance.public_instances[*].public_ip
}
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
