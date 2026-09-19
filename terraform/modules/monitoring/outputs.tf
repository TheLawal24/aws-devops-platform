output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "alarm_names" {
  value = [
    aws_cloudwatch_metric_alarm.alb_unhealthy_hosts.alarm_name,
    aws_cloudwatch_metric_alarm.alb_target_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.ecs_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.ecs_memory.alarm_name
  ]
}
