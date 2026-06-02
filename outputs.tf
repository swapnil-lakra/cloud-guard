output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.cloudguard_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.cloudguard_server.public_dns
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}