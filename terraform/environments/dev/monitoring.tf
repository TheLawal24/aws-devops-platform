module "monitoring" {
  source = "../../modules/monitoring"

  project_name = "aws-devops-platform"
  environment  = var.environment

  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name

  load_balancer_arn_suffix = module.ecs.load_balancer_arn_suffix
  target_group_arn_suffix  = module.ecs.target_group_arn_suffix
}
