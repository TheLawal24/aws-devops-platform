module "ecr" {
  source = "../../modules/ecr"

  project_name = "aws-devops-platform"
  environment  = var.environment
}
