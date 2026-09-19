variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "container_image" {
  description = "Container image URI including immutable tag"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role used by ECS to pull images and write logs"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role assumed by the running application"
  type        = string
}

variable "container_port" {
  description = "Application container port"
  type        = number
  default     = 8080
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the load balancer and ECS service"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the application load balancer"
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
