locals {
  nat_for_private = zipmap(
    keys(var.private_subnets),
    keys(var.public_subnets)
  )
}

##################################################
# IAM
##################################################

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2" {
  name               = "CloudWatchAgentServerRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json

  tags = {
    Name = "${var.name}-cloudwatch-agent-server-role"
  }
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "CloudWatchAgentServerInstanceProfile"
  role = aws_iam_role.ec2.name
}

##################################################
# EC2 Instances
##################################################

resource "aws_instance" "nat" {
  for_each = var.public_subnets

  ami                    = var.ami_id["nat"]
  instance_type          = var.instance_type["nat"]
  key_name               = var.key_name
  subnet_id              = each.value
  vpc_security_group_ids = [var.nat_sg]
  source_dest_check      = false
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  tags = {
    Name = "${var.name}-nat-instance-${each.key}"
  }
}

resource "aws_instance" "kafka" {
  for_each = var.private_subnets

  ami                    = var.ami_id["kafka"]
  instance_type          = var.instance_type["kafka"]
  key_name               = var.key_name
  subnet_id              = each.value
  vpc_security_group_ids = [var.kafka_sg]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  tags = {
    Name = "${var.name}-kafka-node-${each.key}"
  }
}

##################################################
# Route Tables
##################################################

resource "aws_route_table" "public" {
  for_each = var.public_subnets

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-rt-public-subnet-${each.key}"
  }
}

resource "aws_route_table_association" "public" {
  for_each = var.public_subnets

  subnet_id      = each.value
  route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route" "public_nat_instance" {
  for_each = var.public_subnets

  route_table_id         = aws_route_table.public[each.key].id
  gateway_id             = var.igw
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private" {
  for_each = var.private_subnets

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-rt-private-subnet-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = var.private_subnets

  subnet_id      = each.value
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route" "private_nat_instance" {
  for_each = var.private_subnets

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  network_interface_id = aws_instance.nat[
    local.nat_for_private[each.key]
  ].primary_network_interface_id
}
