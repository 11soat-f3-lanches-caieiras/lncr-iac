resource "aws_iam_role" "load_balancer_controller_role" {
  name = "eks-load-balancer-controller-role"
  
  depends_on = [var.oidc_provider]
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.oidc_provider
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")}:aud" = "sts.amazonaws.com",
            "${replace(var.oidc_provider, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller_policy" {
  role       = aws_iam_role.load_balancer_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller_policy_elb_fullaccess" {
  role       = aws_iam_role.load_balancer_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

resource "aws_iam_role_policy" "load_balancer_controller_additional" {
  name = "eks-load-balancer-controller-additional"
  role = aws_iam_role.load_balancer_controller_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeInternetGateways",
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  timeout    = 600

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    }
  ]
  
  values = [
    <<-EOT
    tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Exists"
        effect: "NoSchedule"
    EOT
  ]
  
  depends_on = [kubectl_manifest.load_balancer_service_account]
}

resource "kubectl_manifest" "load_balancer_namespace" {
  yaml_body = data.template_file.load_balancer_namespace.rendered
}

resource "kubectl_manifest" "load_balancer_service_account" {
  yaml_body  = data.template_file.load_balancer_service_account.rendered
}

