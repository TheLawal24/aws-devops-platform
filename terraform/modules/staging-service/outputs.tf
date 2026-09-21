output "service_name" {
  value = aws_ecs_service.staging.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.staging.arn
}

output "listener_port" {
  value = aws_lb_listener.staging.port
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.staging.name
}
