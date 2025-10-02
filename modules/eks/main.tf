locals {
  config = {
    autoScaling = {
      enabled     = true
      minReplicas = 2
      maxReplicas = 2
    }
  }
}

module "aws-auth" {
  depends_on = [module.eks]
  source     = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version    = "~> 20.0"

  aws_auth_roles = [
    {
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]

  manage_aws_auth_configmap = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  enable_cluster_creator_admin_permissions = false
  name                                     = "${var.prefix_name}-${var.environment}-eks"
  kubernetes_version                       = var.cluster_version
  endpoint_public_access                   = var.cluster_endpoint_public_access
  vpc_id                                   = var.vpc_id
  subnet_ids                               = var.private_subnets
  control_plane_subnet_ids                 = var.private_subnets

  enabled_log_types = [
    "scheduler"
  ]

  node_security_group_id = aws_security_group.eks_nodes_sg.id

  eks_managed_node_groups = {
    critical-services-ng = {
      name = "${var.prefix_name}-${var.environment}"

      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = [var.instance_type_node_eks]
      capacity_type  = "ON_DEMAND"

      # Add this to create a custom launch template
      create_launch_template = true
      launch_template_name   = "${var.prefix_name}-${var.environment}-lt"

      # Disable IMDSv1
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
      }

      tags = {
        ticket = "CPD-1821"
      }
      taints = {
        dedicated = {
          key    = "CriticalAddonsOnly"
          value  = "Exists"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  authentication_mode = "API_AND_CONFIG_MAP"

  create_cloudwatch_log_group = false
  create_kms_key              = false
  encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = aws_kms_alias.eks_key_alias.arn
  }

  create_security_group      = false
  create_node_security_group = false
  security_group_id          = aws_security_group.cluster_security_group.id

  addons = {
    kube-proxy = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
    }
    coredns = {
      most_recent          = true
      configuration_values = jsonencode(local.config)
    }
  }
}

# IAM role for EBS CSI driver with IRSA
resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "${var.prefix_name}-${var.environment}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver_role.name
}

#######################################
# Storage Class
#######################################
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type      = "gp3"
    encrypted = "true"
  }
  depends_on = [module.eks]
}

#######################################
# EKS Namespaces
#######################################
resource "kubernetes_namespace" "namespaces" {
  count = length(var.namespaces)

  metadata {
    name = var.namespaces[count.index]
    labels = {
      Name = var.namespaces[count.index]
    }
  }
}

resource "aws_security_group" "cluster_security_group" {
  name        = "${var.prefix_name}-eks-cluster-sg"
  description = "Security Group for EKS Nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Kubernetes API traffic"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.prefix_name}-nodes-sg"
  description = "Security Group for EKS Nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "karpenter.sh/discovery" = "${var.prefix_name}-${var.environment}-eks"
    "Name"                   = "eks-nodes-sg"
  }
}

#######################################
# KMS Key
#######################################
resource "aws_kms_alias" "eks_key_alias" {
  name          = "alias/${var.prefix_name}-${var.environment}-kms"
  target_key_id = aws_kms_key.eks_key.id
}

resource "aws_kms_key" "eks_key" {
  enable_key_rotation     = false
  deletion_window_in_days = 7
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}