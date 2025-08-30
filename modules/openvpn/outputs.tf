output "vpn-instance_arn" {
  description = "OpenVPN instance ARN"
  value       = aws_instance.OpenVPN.arn
}

output "instance_ip" {
  description = "OpenVPN instance IP"
  value       = aws_eip.openvpn_eip.address
}

output "openvpn_credentials" {
  description = "OpenVPN credentials"
  value = {
    username = random_string.openvpn_admin_user.result
    password = random_password.openvpn_admin_password.result
  }
  sensitive = true
}

output "security_group_id" {
  description = "OpenVPN security group ID"
  value       = aws_security_group.openvpn_sg.id
}