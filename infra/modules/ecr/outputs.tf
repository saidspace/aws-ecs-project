# ---------- Values this ECR module hands back ----------
output "repository_url" {
  description = "The ECR repository URL (used by ECS to pull the image)"
  value       = data.aws_ecr_repository.app.repository_url
}