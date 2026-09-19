output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "terraform_ci_role_arn" {
  value = aws_iam_role.terraform_ci.arn
}
