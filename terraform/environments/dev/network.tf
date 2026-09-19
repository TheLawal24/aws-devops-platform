module "network" {
  source = "../../modules/network"

  project_name = "aws-devops-platform"
  environment  = var.environment
  vpc_cidr     = "10.20.0.0/16"

  public_subnets = {
    a = {
      cidr = "10.20.1.0/24"
      az   = "eu-west-2a"
    }

    b = {
      cidr = "10.20.2.0/24"
      az   = "eu-west-2b"
    }
  }

  private_subnets = {
    a = {
      cidr = "10.20.11.0/24"
      az   = "eu-west-2a"
    }

    b = {
      cidr = "10.20.12.0/24"
      az   = "eu-west-2b"
    }
  }
}
