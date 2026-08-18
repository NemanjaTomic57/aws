resource "aws_security_group" "nat" {
  name        = "${var.name}-nat-instance-sg"
  description = "Security group for NAT instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-bastion-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nat_instance_allow_ssh" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow inbound SSH access to the NAT instance from your network (over the internet gateway)"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "nat_instance_allow_http" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow inbound HTTP traffic from servers in the private subnet"

  cidr_ipv4   = var.vpc_cidr
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "nat_instance_allow_https" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow inbound HTTPS traffic from servers in the private subnet"

  cidr_ipv4   = var.vpc_cidr
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "nat_instance_allow_ssh" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow outbound SSH access to the VPC"

  cidr_ipv4   = var.vpc_cidr
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "nat_instance_allow_http" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow outbound HTTP traffic from servers in the private subnet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "nat_instance_allow_https" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow outbound HTTPS traffic from servers in the private subnet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_security_group" "kafka" {
  name        = "${var.name}-kafka-sg"
  description = "Security group for Kafka nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-kafka-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "kafka_allow_ssh" {
  security_group_id = aws_security_group.kafka.id
  description       = "Allow inbound SSH access from NAT instances"

  cidr_ipv4   = var.vpc_cidr
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "kafka_allow_kafka" {
  security_group_id = aws_security_group.kafka.id
  description       = "Allow inbound HTTP traffic from NAT instances"

  cidr_ipv4   = var.vpc_cidr
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

  cidr_ipv4   = var.vpc_cidr
  from_port   = 9092
  ip_protocol = "tcp"
  to_port     = 9093
}
