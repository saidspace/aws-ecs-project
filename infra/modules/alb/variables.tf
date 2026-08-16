# ---------- Inputs this ALB module needs ----------
variable "vpc_id" {
  description = "ID of the VPC to place the ALB and security groups in"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets the ALB spans"
  type        = list(string)
}