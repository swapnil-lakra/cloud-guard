terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.47.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

