output "file_system_id" {
  description = "FSx OpenZFS file system ID"
  value       = aws_fsx_openzfs_file_system.main.id
}

output "file_system_arn" {
  description = "FSx OpenZFS file system ARN"
  value       = aws_fsx_openzfs_file_system.main.arn
}

output "dns_name" {
  description = "DNS name for the file system"
  value       = aws_fsx_openzfs_file_system.main.dns_name
}

output "network_interface_ids" {
  description = "Network interface IDs"
  value       = aws_fsx_openzfs_file_system.main.network_interface_ids
}

output "security_group_id" {
  description = "Security group ID for FSx OpenZFS"
  value       = length(var.security_group_ids) == 0 ? aws_security_group.fsx_sg[0].id : null
}