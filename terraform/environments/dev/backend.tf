terraform {
  backend "s3" {
    bucket       = "aws-devops-platform-tfstate-808935753572-eu-west-2"
    key          = "aws-devops-platform/dev/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
