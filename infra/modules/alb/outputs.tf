# ---------- Values this ALB module hands back ---------- 
output "alb_dns_name" {
  description = "Public DNS name of the load balancer (the live URL)"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group (ECS attaches its container here)"
  value       = aws_lb_target_group.main.arn
}

output "ecs_security_group_id" {
  description = "ID of the ECS container security group (ECS service uses this)"
  value       = aws_security_group.ecs.id
}

output "listener_arn" {
  description = "ARN of the ALB listener (used for ECS dependency ordering)"
  value       = aws_lb_listener.http.arn
}