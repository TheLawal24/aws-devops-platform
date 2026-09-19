output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.app.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}

output "load_balancer_dns_name" {
  value = aws_lb.app.dns_name
}

output "service_name" {
  value = aws_ecs_service.app.name
}

output "service_arn" {
  value = aws_ecs_service.app.id
}
