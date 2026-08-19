variable "domain_name" {
  description = "The domain the certificate is issued for and the hosted zone it lives in (e.g. said-space.com)"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB to alias the domain to"
  type        = string
}

variable "alb_zone_id" {
  description = "AWS-managed zone ID of the ALB (required for the Route 53 alias record)"
  type        = string
}
