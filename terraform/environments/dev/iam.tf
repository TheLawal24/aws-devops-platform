module "iam" {
  source = "../../modules/iam"

  project_name = "aws-devops-platform"
  environment  = var.environment
}
