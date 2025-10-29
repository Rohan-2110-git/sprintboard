# GitHub OIDC provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# IAM role assumed by GitHub Actions via OIDC
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "gha_ecr_pusher" {
  name = "${var.project}-${var.environment}-gha-ecr-pusher"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRoleWithWebIdentity",
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn },
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        },
        # TODO: tighten to your repo later, e.g. "repo:YourUser/sprintboard:*"
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:*/*:*"
        }
      }
    }]
  })
}

# Inline policy to push/pull images to your two ECR repos
resource "aws_iam_role_policy" "gha_ecr_policy" {
  name = "${var.project}-${var.environment}-gha-ecr-policy"
  role = aws_iam_role.gha_ecr_pusher.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ECRAuth"
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "ECRPushPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = [
          aws_ecr_repository.api.arn,
          aws_ecr_repository.frontend.arn
        ]
      }
    ]
  })
}

output "gha_role_arn" {
  value = aws_iam_role.gha_ecr_pusher.arn
}
