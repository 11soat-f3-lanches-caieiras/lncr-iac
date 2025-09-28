output "codebuild_project_names" {
  description = "Map of CodeBuild project names"
  value       = { for k, v in aws_codebuild_project.projects : k => v.name }
}

output "codebuild_project_arns" {
  description = "Map of CodeBuild project ARNs"
  value       = { for k, v in aws_codebuild_project.projects : k => v.arn }
}

output "codebuild_role_arn" {
  description = "CodeBuild IAM role ARN"
  value       = aws_iam_role.codebuild_role.arn
}

output "codebuild_security_group_id" {
  description = "CodeBuild security group ID"
  value       = aws_security_group.codebuild_sg.id
}

output "codebuild_webhook_urls" {
  description = "Map of CodeBuild webhook URLs for GitHub integration"
  value       = { for k, v in aws_codebuild_webhook.github_runner_webhook : k => v.url }
}