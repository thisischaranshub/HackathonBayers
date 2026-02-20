resource "aws_ecr_repository" "ecr_repositories" {
  for_each             = toset(var.ecr_repo_names)

  name                 = each.value
  tags                 = var.tags
}

# locals {
#   ecr_repo_names = [for base_name in var.ecr_repo_names : "${base_name}-${var.environment}"]
# }

# resource "aws_ecr_repository" "repositories" {
#   for_each = toset(local.ecr_repo_names)

#   name = each.value
#   tags = var.tags
# }

# resource "aws_ecr_lifecycle_policy" "keep_last_5_images" {
#   for_each             = toset(var.ecr_repo_names)
#   repository           = each.value

#   policy = jsonencode({
#     rules = [
#       {
#         rulePriority = 1,
#         description  = "Keep only the last 5 images",
#         selection = {
#           tagStatus   = "any",
#           countType   = "imageCountMoreThan",
#           countNumber = 5
#         },
#         action = {
#           type = "expire"
#         }
#       }
#     ]
#   })
# }