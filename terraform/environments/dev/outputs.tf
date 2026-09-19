output "aws_account_id" {
  description = "AWS account ID Terraform is authenticated against"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region Terraform is configured to use"
  value       = data.aws_region.current.region
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "alb_security_group_id" {
  value = module.network.alb_security_group_id
}

output "ecs_security_group_id" {
  value = module.network.ecs_security_group_id
}
