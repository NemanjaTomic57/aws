variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "igw" {
  type = string
}

variable "public_subnets" {
  type = map(string)
}

variable "private_subnets" {
  type = map(string)
}

variable "nat_sg" {
  type = string
}

variable "kafka_sg" {
  type = string
}

variable "ami_id" {
  type = map(string)
}

variable "instance_type" {
  type = map(string)
}

variable "key_name" {
  type = string
}
