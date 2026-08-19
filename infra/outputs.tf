# ---------- App's URL and cluster name ----------
output "app_url" {
  description = "Public URL of the deployed app"
  value       = "https://${var.domain_name}"
}

output "ecs_cluster" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "github_actions_role_arn" {
  value = module.iam.role_arn
}
