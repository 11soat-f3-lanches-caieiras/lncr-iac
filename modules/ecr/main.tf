#========================================================================================#
#                                  ECR REPOSITORIES                                      #
#========================================================================================#

resource "aws_ecr_repository" "repositories" {
  for_each = toset(var.repository_names)

  name                 = "${var.prefix_name}-${var.environment_name}-${each.value}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = "${var.prefix_name}-${each.value}"
    Environment = var.environment_name
    Owner       = "Fiap"
    CostCenter  = "FinOps"
  }
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  for_each = var.lifecycle_policy != "" ? aws_ecr_repository.repositories : {}

  repository = each.value.name
  policy     = var.lifecycle_policy != "" ? var.lifecycle_policy : local.default_lifecycle_policy
}

#========================================================================================#
#                                  LOCAL VALUES                                          #
#========================================================================================#

locals {
  default_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}