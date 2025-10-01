data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "template_file" "load_balancer_namespace" {
  template = file("${path.module}/templates/namespace.yaml")
}

data "template_file" "load_balancer_controller_sa" {
  template = file("${path.module}/templates/service-account.yaml")
  
  vars = {
    role_arn = aws_iam_role.load_balancer_controller_role.arn
  }
}

data "template_file" "default_ingress" {
  template = file("${path.module}/templates/default-ingress.yaml")

  vars = {
    group_name     = var.group_name
    alb_sg         = var.alb-sg
    public_subnets = join(",", var.public_subnets)
    namespace      = var.namespace
    alb_name       = var.alb_name
  }
}