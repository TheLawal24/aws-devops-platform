module "github_oidc" {
  source = "../../modules/github-oidc"

  github_owner      = "TheLawal24"
  github_repository = "aws-devops-platform"
  github_branch     = "main"

  project_name = "aws-devops-platform"
  environment  = var.environment

  ecr_repository_arn = module.ecr.repository_arn
  ecs_cluster_arn    = module.ecs.cluster_arn
  ecs_service_name   = module.ecs.service_name

  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
}
