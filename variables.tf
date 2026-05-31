variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name tag"
  type        = string
  default     = "CloudGuard"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID for ap-south-1"
  type        = string
  default     = "ami-07a00cf47dbbc844c"
}

variable "key_name" {
  description = "EC2 key pair name for SSH"
  type        = string
}