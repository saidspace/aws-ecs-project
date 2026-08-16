# ---------- Reference the existing ECR repository ----------

# Repo + image already exist, so we look them up with a data source instead of creating them
data "aws_ecr_repository" "app" {
  name = var.repository_name
}