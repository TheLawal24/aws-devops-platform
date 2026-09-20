output "sns_alert_topic_arn" {
  description = "SNS topic used by CloudWatch alarms"
  value       = module.monitoring.sns_topic_arn
}

output "cloudwatch_alarm_names" {
  value = module.monitoring.alarm_names
}
