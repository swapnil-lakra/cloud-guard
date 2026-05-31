terraform {
  backend "s3" {
    bucket       = "cloudguard-tfstate-598120810611"
    key          = "cloudguard-infra/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = false
    encrypt      = true
  }
}