output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.cloudguard_server.public_ip
}

output "ec2_public_dn" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.cloudguard_server.public_dns
}