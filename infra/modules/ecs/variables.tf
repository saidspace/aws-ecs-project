# ---------- Inputs for ECS module ----------
variable "image_url" {
  description = "ECR repository URL for the container image"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets to run the ECS tasks in"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group for the ECS tasks (allows 8080 from the ALB)"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group the service registers with"
  type        = string
}

variable "listener_dependency" {
  description = "ALB listener ARN, used to enforce creation order"
  type        = string
}