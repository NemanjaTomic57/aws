output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "igw" {
  value = aws_internet_gateway.this.id
}

output "public_subnet_ids" {
  description = "Names and IDs of the public subnets"
  value = {
    for name, subnet in aws_subnet.public : name => subnet.id
  }
}

output "private_subnet_ids" {
  description = "Names and IDs of the private subnets"
  value = {
    for name, subnet in aws_subnet.private : name => subnet.id
  }
}
