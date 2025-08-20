resource "aws_ecr_repository" "app_repo" {
  name = "aws-devops-thrive-app"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "aws-devops-thrive-app"
    Environment = "dev"
  }
}

output "ecr_repository_url" {
  description = "URL of the ECR repo"
  value       = aws_ecr_repository.app_repo.repository_url
}
