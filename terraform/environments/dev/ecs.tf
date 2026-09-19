module "ecs" {
  source = "../../modules/ecs"

  project_name       = "aws-devops-platform"
  environment        = var.environment
  aws_region         = var.aws_region
  container_image    = "${module.ecr.repository_url}:v4"
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  container_port     = 8080

  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
  ecs_security_group_id = module.network.ecs_security_group_id
}
