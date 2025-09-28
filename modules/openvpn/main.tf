#========================================================================================#
#                                SECURITY GROUP                                          #
#========================================================================================#

resource "aws_security_group" "openvpn_sg" {
  name        = "${var.prefix_name}-${var.environment_name}-vpn-sg"
  vpc_id      = var.vpc_id
  description = "OpenVPN Security Group"

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-vpn-sg"
    CostCenter  = "FinOps"
    Environment = var.environment_name
    Owner       = "fiap"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080_tcp_ipv4" {
  security_group_id = aws_security_group.openvpn_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
  description       = "Allow all-traffic from Internet to HTTP port"
}

resource "aws_vpc_security_group_ingress_rule" "allow_1194_udp_ipv4" {
  security_group_id = aws_security_group.openvpn_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 1194
  ip_protocol       = "udp"
  to_port           = 1194
  description       = "Allow all-traffic from Internet to UDP port"
}

resource "aws_vpc_security_group_egress_rule" "openvpn_egress" {
  security_group_id = aws_security_group.openvpn_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow All Traffic to internet"
}

#========================================================================================#
#                           ROLES AND POLICIES RESOURCES                                 #
#========================================================================================#

resource "aws_iam_role" "EC2InstanceConnectRole" {
  name = "${var.prefix_name}-openvpn-${var.environment_name}-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "EC2InstanceConnectPolicy" {
  name = "${var.prefix_name}-ec2instanceconnect-openvpn-${var.environment_name}-Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ec2-instance-connect:SendSSHPublicKey"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "S3PutPolicy" {
  name = "${var.prefix_name}-s3put-openvpn-${var.environment_name}-Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.OpenVPN-bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.OpenVPN-bucket.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "SSMMessagesPolicy" {
  name = "${var.prefix_name}-ssmmessages-openvpn-${var.environment_name}-Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "EC2InstanceConnectRole_attachment_s3putPolicy" {
  role = aws_iam_role.EC2InstanceConnectRole.name

  policy_arn = aws_iam_policy.S3PutPolicy.arn
}
resource "aws_iam_role_policy_attachment" "EC2InstanceConnectRole_attachment_ssmMessagePolicy" {
  role = aws_iam_role.EC2InstanceConnectRole.name

  policy_arn = aws_iam_policy.SSMMessagesPolicy.arn
}
resource "aws_iam_role_policy_attachment" "EC2InstanceConnectRole_attachment_ec2InstanceConnectPolicy" {
  role = aws_iam_role.EC2InstanceConnectRole.name

  policy_arn = aws_iam_policy.EC2InstanceConnectPolicy.arn
}
resource "aws_iam_role_policy_attachment" "EC2InstanceConnectRole_attachment_cwAgentServerPolicy" {
  role = aws_iam_role.EC2InstanceConnectRole.name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "OpenVPN_IAM_Profile" {
  name = "${var.prefix_name}-openvpn-${var.environment_name}-profile"
  role = aws_iam_role.EC2InstanceConnectRole.name
}

#========================================================================================#
#                           PRIVATE / PAIR KEY RESOURCES                                 #
#========================================================================================#

resource "tls_private_key" "private-key-oVPN" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key-pair-oVpn" {
  key_name   = format("%s-key", var.prefix_name)
  public_key = tls_private_key.private-key-oVPN.public_key_openssh
}

#========================================================================================#
#                                  S3 RESOURCES                                          #
#========================================================================================#

resource "aws_s3_bucket" "OpenVPN-bucket" {
  bucket        = "${var.prefix_name}-openvpn-${var.environment_name}-bucket-fiap"
  force_destroy = true
}


resource "aws_s3_object" "pastaChaveBucket" {
  bucket = aws_s3_bucket.OpenVPN-bucket.bucket
  key    = "chave/"
  source = "/dev/null" # Usar um arquivo vazio para criar o "diretório"
}

resource "aws_s3_object" "private-key-pair-file" {
  depends_on = [aws_s3_object.pastaChaveBucket]

  bucket  = aws_s3_bucket.OpenVPN-bucket.bucket
  key     = format("chave/%s/%s.pem", aws_instance.OpenVPN.id, aws_key_pair.key-pair-oVpn.key_name)
  content = tls_private_key.private-key-oVPN.private_key_pem # Usar 'content' ao invés de 'source'
}


#========================================================================================#
#                               CREDENTIALS RESOURCES                                    #
#========================================================================================#

resource "random_string" "openvpn_admin_user" {
  length           = 16
  special          = false
  upper            = false
  lower            = true
  numeric          = true
  override_special = "!@#$%^&*"
}

resource "random_password" "openvpn_admin_password" {
  length           = 16
  special          = false
  upper            = false
  lower            = true
  numeric          = true
  override_special = "!@#$%^&*"
}

resource "aws_secretsmanager_secret" "openvpn_secrets" {
  name                    = "${var.prefix_name}-openvpn-${var.environment_name}-secrets"
  description             = "${var.prefix_name} secrets for OpenVPN"
  recovery_window_in_days = 0

  tags = {
    CostCenter  = "FinOps"
    Environment = "${var.environment_name}"
    Owner       = "fiap"
  }
}

resource "aws_secretsmanager_secret_version" "openvpn_credentials_secrets" {
  secret_id = aws_secretsmanager_secret.openvpn_secrets.id
  secret_string = jsonencode({
    username = random_string.openvpn_admin_user.result
    password = random_password.openvpn_admin_password.result
  })
}

#========================================================================================#
#                                  EC2 RESOURCES                                         #
#========================================================================================#

resource "aws_instance" "OpenVPN" {
  depends_on    = [random_string.openvpn_admin_user, random_password.openvpn_admin_password]
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.key-pair-oVpn.key_name

  iam_instance_profile = aws_iam_instance_profile.OpenVPN_IAM_Profile.name

  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.openvpn_sg.id]

  ipv6_address_count = 0

  tags = {
    Name        = "${var.prefix_name}-openvpn-${var.environment_name}-ec2"
    CostCenter  = "FinOps"
    Environment = "${var.environment_name}"
    Owner       = "fiap"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  user_data = data.template_file.user_data.rendered

  lifecycle {
    ignore_changes = [ami]
  }
}


