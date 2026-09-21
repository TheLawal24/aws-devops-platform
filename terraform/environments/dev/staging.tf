module "staging" {
  source = "../../modules/staging-service"

  project_name = "aws-devops-platform"
  aws_region   = var.aws_region

  cluster_id        = module.ecs.cluster_arn
  load_balancer_arn = module.ecs.load_balancer_arn

  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  ecs_security_group_id = module.network.ecs_security_group_id

  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn

  container_image = "808935753572.dkr.ecr.eu-west-2.amazonaws.com/aws-devops-platform-dev:ec0881e7896b53088592128b418f6dbd36cccd98"
  container_port  = 8080
}
