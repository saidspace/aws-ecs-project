# ---------- Inputs this VPC module needs ----------
variable "vpc_cidr" {
  description = "The IP address range for the VPC"
  type        = string
}

variable "azs" {
    description = "The 2 Availability Zones to place subnets in"
    type        = list(string)


}