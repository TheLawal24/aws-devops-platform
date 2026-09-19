output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_task_definition_arn" {
  value = module.ecs.task_definition_arn
}

output "ecs_log_group_name" {
  value = module.ecs.log_group_name
}

output "application_url" {
  value = "http://${module.ecs.load_balancer_dns_name}"
}

output "ecs_service_name" {
  value = module.ecs.service_name
}
