

resource "aws_codebuild_project" "infra_project" {
  name         = "${var.prefix_name}-codebuild-infra-project"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = var.compute_type
    image        = var.image
    type         = "LINUX_CONTAINER"
    privileged_mode = true
  }

  vpc_config {
    vpc_id = var.vpc_id
    subnets = var.subnet_ids
    security_group_ids = [aws_security_group.codebuild_sg.id]
  }

  source {
    type = "GITHUB"
    location = var.github_repo_url
  }

  tags = {
    Name        = "${var.prefix_name}-codebuild-infra-project"
    Environment = var.environment_name
    Owner       = "Fiap"
    CostCenter  = "FinOps"
  }
}

resource "aws_security_group" "codebuild_sg" {
  name_prefix = "${var.prefix_name}-codebuild-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix_name}-codebuild-sg"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "${var.prefix_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.prefix_name}-codebuild-role"
    Environment = var.environment_name
    Owner       = "Fiap"
    CostCenter  = "FinOps"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.prefix_name}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ec2:CreateNetworkInterfacePermission"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "*"
        Resource = "*"
      }
    ]
  })
}