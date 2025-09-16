output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.infra_project.name
}

output "codebuild_fleet_name" {
  description = "CodeBuild fleet name for GitHub Actions"
  value       = aws_codebuild_fleet.github_runner_fleet.name
}

output "codebuild_project_arn" {
  description = "CodeBuild project ARN"
  value       = aws_codebuild_project.infra_project.arn
}

output "codebuild_role_arn" {
  description = "CodeBuild IAM role ARN"
  value       = aws_iam_role.codebuild_role.arn
}

output "codebuild_security_group_id" {
  description = "CodeBuild security group ID"
  value       = aws_security_group.codebuild_sg.id
}