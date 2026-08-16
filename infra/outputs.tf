# ---------- App's URL and cluster name ----------
output "app_url" {
  description = "Public URL of the deployed app"
  value       = "http://${module.alb.alb_dns_name}"
}

output "ecs_cluster" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}