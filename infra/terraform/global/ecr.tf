resource "aws_ecr_repository" "api" {
  name                 = "sprintboard-api"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
}

resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name
  policy     = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Keep last 15 images",
      selection    = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 15 },
      action       = { type = "expire" }
    }]
  })
}

resource "aws_ecr_repository" "frontend" {
  name                 = "sprintboard-frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
}

resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = aws_ecr_repository.frontend.name
  policy     = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Keep last 15 images",
      selection    = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 15 },
      action       = { type = "expire" }
    }]
  })
}

output "ecr_api_url"      { value = aws_ecr_repository.api.repository_url }
output "ecr_frontend_url" { value = aws_ecr_repository.frontend.repository_url }
