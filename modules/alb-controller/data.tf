data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "template_file" "load_balancer_namespace" {
  template = file("${path.module}/templates/namespace.yaml")
}

data "template_file" "load_balancer_service_account" {
  template = file("${path.module}/templates/service-account.yaml")
  
  vars = {
    role_arn = aws_iam_role.load_balancer_controller_role.arn
  }
}
