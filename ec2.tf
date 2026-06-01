resource "aws_instance" "cloudguard_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = aws_subnet.public_1.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 30 # 30 GB free tier eligible
    volume_type = "gp2"
  }

  user_data_base64 = base64encode(templatefile("${path.module}/user-data.sh", {}))

  tags = {
    Name = "${var.project_name}-server"
  }
}