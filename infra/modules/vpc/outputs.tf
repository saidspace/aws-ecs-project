# ---------- Values this VPC module returns to caller ----------
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the two public subnets"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}