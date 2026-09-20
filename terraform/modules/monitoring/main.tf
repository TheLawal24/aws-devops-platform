resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = {
    Name = "${var.project_name}-${var.environment}-alerts"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy-hosts"
  alarm_description   = "ALB has one or more unhealthy ECS targets"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 1
  period              = 60
  statistic           = "Maximum"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-target-5xx"
  alarm_description   = "Application is returning excessive HTTP 5XX responses"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 5
  period              = 300
  statistic           = "Sum"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-high-cpu"
  alarm_description   = "ECS service CPU utilization is above 80 percent"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 80
  period              = 300
  statistic           = "Average"

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-high-memory"
  alarm_description   = "ECS service memory utilization is above 80 percent"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 80
  period              = 300
  statistic           = "Average"

  namespace   = "AWS/ECS"
  metric_name = "MemoryUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
