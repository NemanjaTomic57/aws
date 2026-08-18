variable "name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
}
