variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "pub_sub_count" {
  description = "Number of public subnets"
  type        = number
}

variable "priv_sub_count" {
  description = "Number of private subnets"
  type        = number
}

variable "nat_count" {
  description = "Number of NAT gateways"
  type        = number
}
variable "public_instance" {
  description = "Number of public EC2 instances to create"
  type        = number
}