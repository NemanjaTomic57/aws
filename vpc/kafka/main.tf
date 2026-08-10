terraform {
  backend "s3" {
    bucket = "terraform-761018874759"
    key    = "aws/vpc/kafka.tfstate"
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

##################################################
# VPC
##################################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

##################################################
# Internet Gateway
##################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

##################################################
# Availability Zones
##################################################

data "aws_availability_zones" "available" {
  state = "available"
}

##################################################
# Public Subnets
##################################################

resource "aws_subnet" "public" {
  for_each = { for i, cidr in var.public_subnet_cidrs : i => cidr }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[each.key]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-subnet-${each.key}"
  }
}

##################################################
# Private Subnets
##################################################

resource "aws_subnet" "private" {
  for_each = { for i, cidr in var.private_subnet_cidrs : i => cidr }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[each.key]

  tags = {
    Name = "${var.name}-private-subnet-${each.key}"
  }
}

##################################################
# Security Groups
##################################################

resource "aws_security_group" "nat_instance" {
  name        = "${var.name}-nat-instance-sg"
  description = "Security group for NAT instances"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.name}-bastion-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nat_instance_allow_ssh" {
  security_group_id = aws_security_group.nat_instance.id
  description       = "Allow inbound SSH access to the NAT instance from your network (over the internet gateway)"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "nat_instance_allow_http" {
  security_group_id = aws_security_group.nat_instance.id
  description       = "Allow inbound HTTP traffic from servers in the private subnet"

  cidr_ipv4   = aws_vpc.this.cidr_block
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "nat_instance_allow_https" {
  security_group_id = aws_security_group.nat_instance.id
  description       = "Allow inbound HTTPS traffic from servers in the private subnet"

  cidr_ipv4   = aws_vpc.this.cidr_block
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "nat_instance_allow_ssh" {
  security_group_id = aws_security_group.nat_instance.id
  description       = "Allow outbound SSH access to the VPC"

  cidr_ipv4   = aws_vpc.this.cidr_block
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "nat_instance_allow_http" {
  security_group_id = aws_security_group.nat_instance.id
  description       = "Allow outbound HTTP traffic from servers in the private subnet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "nat_instance_allow_https" {
  security_group_id = aws_security_group.nat_instance.id
  description       = "Allow outbound HTTPS traffic from servers in the private subnet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_security_group" "kafka" {
  name        = "${var.name}-kafka-sg"
  description = "Security group for Kafka nodes"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.name}-kafka-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "kafka_allow_ssh" {
  security_group_id = aws_security_group.kafka.id
  description       = "Allow inbound SSH access from NAT instances"

  cidr_ipv4   = aws_vpc.this.cidr_block
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "kafka_allow_kafka" {
  security_group_id = aws_security_group.kafka.id
  description       = "Allow inbound HTTP traffic from NAT instances"

  cidr_ipv4   = aws_vpc.this.cidr_block
  from_port   = 9092
  ip_protocol = "tcp"
  to_port     = 9093
}

resource "aws_vpc_security_group_egress_rule" "kafka_allow_http" {
  security_group_id = aws_security_group.kafka.id
  description       = "Allow outbound HTTP traffic from NAT instances"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "kafka_allow_https" {
  security_group_id = aws_security_group.kafka.id
  description       = "Allow outbound HTTPS traffic from NAT instances"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "kafka_allow_kafka" {
  security_group_id = aws_security_group.kafka.id
  description       = "Allow outbound HTTP traffic from NAT instances"

  cidr_ipv4   = aws_vpc.this.cidr_block
  from_port   = 9092
  ip_protocol = "tcp"
  to_port     = 9093
}

##################################################
# EC2 Instances
##################################################

resource "aws_instance" "nat" {
  for_each = aws_subnet.public

  ami                    = var.ami_id["nat"]
  instance_type          = var.instance_type["nat"]
  key_name               = var.key_name
  subnet_id              = each.value.id
  vpc_security_group_ids = [aws_security_group.nat_instance.id]
  source_dest_check      = false

  tags = {
    Name = "${var.name}-nat-instance-${each.key}"
  }
}

resource "aws_instance" "kafka" {
  for_each = aws_subnet.private

  ami                    = var.ami_id["kafka"]
  instance_type          = var.instance_type["kafka"]
  key_name               = var.key_name
  subnet_id              = each.value.id
  vpc_security_group_ids = [aws_security_group.kafka.id]

  tags = {
    Name = "${var.name}-kafka-node-${each.key}"
  }
}

##################################################
# Route Tables
##################################################

resource "aws_route_table" "public" {
  for_each = aws_subnet.public

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-rt-public-subnet-${each.key}"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route" "public_nat_instance" {
  for_each = aws_subnet.public

  route_table_id         = aws_route_table.public[each.key].id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-rt-private-subnet-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route" "private_nat_instance" {
  for_each = aws_subnet.private

  route_table_id         = aws_route_table.private[each.key].id
  network_interface_id   = aws_instance.nat[each.key].primary_network_interface_id
  destination_cidr_block = "0.0.0.0/0"
}
