#========================================================================================#
#                                   AMI DATAS                                            #
#========================================================================================#

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_eip" "openvpn_eip" {
  instance = aws_instance.OpenVPN.id
  domain   = "vpc"

  tags = {
    Name = "openvpn-eip"
  }
}

#========================================================================================#
#                                  TEMPLATE DATA                                         #
#========================================================================================#

data "template_file" "user_data" {
  depends_on = [random_password.openvpn_admin_password, random_string.openvpn_admin_user]
  template   = file("${path.module}/templates/user_data.sh")

  vars = {
    admin_username = random_string.openvpn_admin_user.result
    admin_password = random_password.openvpn_admin_password.result
    prefix_name    = var.prefix_name
  }
}

