# ---------- Inputs this ECR module needs ----------
variable "repository_name" {
  description = "Name of the existing ECR repository to reference"
  type        = string
}