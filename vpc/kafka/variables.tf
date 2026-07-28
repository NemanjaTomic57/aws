variable "name" {
  type    = string
  default = "nat-instance-getting-started"
}

variable "ami_id" {
  type = map(string)

  default = {
    nat   = "ami-0d48b1c648cd339e0",
    kafka = "ami-0723bff07f72bb394"
  }
}

variable "key_name" {
  type    = string
  default = "aws"
}

variable "instance_type" {
  type = map(string)

  default = {
    nat   = "t4g.micro"
    kafka = "t4g.medium"
  }
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "192.168.0.0/24",
    "192.168.1.0/24",
    "192.168.2.0/24",
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "192.168.32.0/24",
    "192.168.33.0/24",
    "192.168.34.0/24",
  ]
}
