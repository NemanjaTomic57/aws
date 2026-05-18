provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = var.tag_name
    }
  }
}

##############################################
# VPC
##############################################
resource "aws_vpc" "kubernetes" {
  cidr_block = "192.168.0.0/16"
}

##############################################
# Internet Gateway
##############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.kubernetes.id
}

resource "aws_route_table" "rt_public_sn" {
  vpc_id = aws_vpc.kubernetes.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt_association_public_sn" {
  route_table_id = aws_route_table.rt_public_sn.id
  subnet_id      = aws_subnet.public.id
}

##############################################
# NAT Gateway
##############################################
resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.eip.id

  depends_on = [aws_eip.eip]
}

resource "aws_route_table" "rt_private_sn" {
  vpc_id = aws_vpc.kubernetes.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
}

resource "aws_route_table_association" "rt_association_private_sn" {
  route_table_id = aws_route_table.rt_private_sn.id
  subnet_id      = aws_subnet.private.id
}

##############################################
# Subnets
##############################################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.kubernetes.id
  cidr_block              = "192.168.0.0/22"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.kubernetes.id
  cidr_block = "192.168.64.0/22"
}

##############################################
# Security Groups
##############################################
resource "aws_security_group" "public" {
  name        = "kubernetes-sg-public"
  description = "Allow SSH to bastion host."
  vpc_id      = aws_vpc.kubernetes.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_public" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4         = var.luconsult_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_public" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4         = aws_subnet.private.cidr_block
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_security_group" "private" {
  name        = "kubernetes-sg-private"
  description = "Allow all traffic between nodes and SSH to bastion."
  vpc_id      = aws_vpc.kubernetes.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_vpc_traffic" {
  security_group_id = aws_security_group.private.id
  cidr_ipv4         = aws_vpc.kubernetes.cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_vpc_traffic" {
  security_group_id = aws_security_group.private.id
  cidr_ipv4         = aws_vpc.kubernetes.cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_pod_traffic" {
  security_group_id = aws_security_group.private.id
  cidr_ipv4         = "10.10.0.0/16"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_pod_traffic" {
  security_group_id = aws_security_group.private.id
  cidr_ipv4         = "10.10.0.0/16"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_https" {
  security_group_id = aws_security_group.private.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

##############################################
# EC2
##############################################
resource "aws_key_pair" "main" {
  key_name   = "vpc-kubernetes"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAA2Zrd3/LWxuGn2m/+yXpF34IcSQK+V+jKWMAQ/7LS+ nemanja.tomic@ik.me"
}

resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.main.key_name

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public.id]

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_instance" "controlplanes" {
  count = 3

  ami           = var.ami_id
  instance_type = "t3.small"
  key_name      = aws_key_pair.main.key_name

  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]

  tags = var.tag_instance_controlplane
}

resource "aws_instance" "workers" {
  count = 3

  ami           = var.ami_id
  instance_type = "t3.small"
  key_name      = aws_key_pair.main.key_name

  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]

  tags = var.tag_instance_worker
}
