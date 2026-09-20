output "github_actions_role_arn" {
  value = module.github_oidc.github_actions_role_arn
}

output "terraform_ci_role_arn" {
  value = module.github_oidc.terraform_ci_role_arn
}

output "terraform_apply_role_arn" {
  value = module.github_oidc.terraform_apply_role_arn
}
